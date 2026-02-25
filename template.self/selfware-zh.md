# Selfware

> A file is an app. Everything is a file.
>
> Selfware 定义一种 Agent 时代的统一文件协议：在同一可分发单元（文件或 `.self` 包）内，实现数据、逻辑与视图的可选一体化；以分布式、去中心化的 Agent 协同方式与自包含的人机互动方式，构建人↔Agent、Agent↔Agent 的协作关系；让文件回归到用户，永不失效，无限进化。

Version: 0.1.0 (Draft)

License (Optional): MIT — you MAY modify, redistribute, and create derivatives.

除非标注为“Non‑Normative”，本文使用 RFC 风格术语：
- **MUST / MUST NOT**：必须 / 禁止
- **SHOULD / SHOULD NOT**：应当 / 不应当
- **MAY**：可以

---

## 1. Canonical Data Authority（数据权威源）

Selfware **不要求**“协议/应用”必须被写成单文件；但它 **要求**：对任意 Selfware 实例，必须清晰声明且严格遵守“数据权威源（Canonical Data Source）”。

对一个 Selfware 实例而言，**内容真理源（Canonical Data）MUST 只来自以下两类来源之一**：
1. **本地 Canonical Data**：位于实例的 `content/` 范围内（默认写入范围）。
2. **远程 Canonical Data**：由 `manifest.md` 显式声明的远程数据源（例如 http(s)/git 等可解析指针），并由运行时定义其同步/缓存/合并策略（但 MUST 遵守 No Silent Apply 与回滚要求）。

约束（MUST）：
- Kernel、Views、Assets、Skills 等均属于运行时实现（runtime），MAY 被替换或由 Agent 重新生成。
- Views MUST NOT 成为内容真理源（禁止把 Canonical Data 硬编码进视图文件作为唯一来源）。
- 任何会改变 Canonical Data 的动作，都 MUST 落在 `content/`（或其被 manifest 声明为 canonical 的等价落点）并可回滚；在未获用户确认前 MUST NOT 静默应用远程变更。

对比传统软件：传统软件通常把“数据”和“逻辑/视图”分离，逻辑与视图由少数大厂通过闭源客户端/服务端掌控，从而实现对文件与生态的事实垄断。Selfware 通过 **数据 + 逻辑 + 视图** 在同一文件（或同一可分发包）内的可选实现，以及 **非中心化** 的运行/分发方式，从根本上移除任何单一主体对软件定义权的垄断。本协议本身也是一个可选项 MIT 协议，你可以任意修改、分发、创造。这是 Agent 时代 的统一文件协议，也是打破藩篱、进入新世界的开始。

---

## 2. Canonical Data（规范数据）

本 demo 的 Canonical Data 为：
- `content/selfware_demo.md`（文本/Markdown；用于前端读取/编辑/保存）

说明：
- `content/` 是**实例的规范数据范围**（canonical data scope / 默认写入范围）；协作、保存、合并等写入默认都在这里发生。
- 实例 MAY 在 `manifest.md` 中声明 **远程 Canonical Data**，作为“内容真理源”的获取/同步来源之一。

远程 Canonical Data（示例；仅示例，不构成默认值）：
- `Remote Canonical: https://floatboat.ai/selfware.md`
- `Remote Canonical: git:https://github.com/floatboatai/selfware.md`

实现约束（MUST）：
- 若启用远程 Canonical Data，运行时 MUST 明确其策略（只读/同步/合并）并遵守 **6.3 No Silent Apply**（告知逻辑 + 摘要/diff + 回滚点 + 用户确认）。

Selfware 允许 Canonical Data 是任意数据类型（非穷尽）：
- 文本 / Markdown
- JSON / YAML
- 二进制（图片、音频、视频）
- 数据库文件（SQLite 等）
- 代码与工程文件
- Office 文档（docx 等）

实现 MUST 明确 Canonical Data 的读取/写入形状（文本、字节流、或命名资源集）。

---

## 3. View as Function（视图即函数）

任何视图 MUST 被视为函数：
> `View = f(Data, Intent, Rules)`

其中：
- `Data` 来自 Canonical Data
- `Rules` 由本文件定义（或本文件允许的扩展）
- Views MUST NOT 成为内容真理源（禁止把 Canonical Data 硬编码进视图文件作为唯一来源）

---

## 4. Runtime API（运行时接口）

Kernel MUST bind to loopback only（`localhost/127.0.0.1/::1`），除非用户显式配置更宽边界。

本 demo 的 API：
- `GET /api/content` -> `{ "content": "<content/selfware_demo.md>" }`
- `POST /api/save` with `{ "content": "<content/selfware_demo.md>" }` -> `{ "status": "success" }`
- `GET /api/self` -> `{ "path": "...", "sha256": "...", "content": "<content/selfware_demo.md>" }`
- `GET /api/manifest` -> `{ "content": "<manifest.md>" }`
- `GET /api/capabilities` -> 运行时能力声明（见 4.1）
- `GET /api/check_update?url=...` -> 检查远程协议源是否更新（见 6）

写入边界（MUST）：
- `POST /api/save` MUST only write within `content/` (canonical data scope)
- 运行时 MUST NOT 在未经用户明确意图与确认的情况下写入 `selfware.md`

### 4.1 Capability Declaration（能力声明）

运行时 MUST 声明自身能力，以便用户与其它 Agent 明确边界与交互方式。

声明内容 MUST 至少包含：
- `write_scope`：允许写入的范围（本 demo 为 `content/`）
- `confirmation_required`：必须用户确认的动作集合（例如 pack、pull/merge、apply update、publish、send context）
- `endpoints`：可用接口与其用途（包括内容读写、更新检查、打包等）
- `modules`：可选模块状态（例如 git/discovery/self‑analysis 是否支持/是否启用）

声明载体（实现 MUST 提供至少一种）：
- **机器可读**：例如 `GET /api/capabilities`
- **人类可读**：例如启动时打印摘要或 UI 面板

交互约束（MUST）：
- 若运行时/Agent 发现“某项能力已支持，但尚未启用/尚缺配置/存在多种策略分支”（例如启用远端协作、开启 Discovery、执行 publish、记录 runs 等），MUST **先向用户提出问题**并获得明确确认后，才允许执行会产生写入或对外通信的动作。
- 任何由上述询问触发的写入/应用，仍必须满足：写入边界（`content/`）与变更元数据（Change Record）要求。

---

## 5. Discovery（发现）

Discovery endpoint 示例（仅示例，不构成默认值）：
- `https://floatboat.ai/discovery/`
- `https://github.com/awesome-selfware/awesome-selfware`（GitHub 索引仓库：用于发现 Selfware/Skills/Practices 等生态条目）

Discovery 的目标：在**用户许可**下，携带“意图 + 部分上下文”，去发现更好的解决方案（而不是仅仅搜索）。

Discovery 请求 SHOULD 包含：
- **Intent（意图）**：当前任务目标/希望达成的结果（例如 `update`、`recommend`、`fix_overflow`、`export_cards`）。
- **Partial Context（部分上下文）**：与意图直接相关的最小信息集，例如：
  - 任务目标（goal）
  - 执行状态（state / progress）
  - 执行日志（logs，**可选**，且必须可裁剪/脱敏）

权限（MUST）：
- 任何包含上下文的 Discovery 请求 MUST 在用户明确许可下发送。
- 默认 SHOULD 只发送最小必要上下文；更高粒度上下文必须单独授权。

Discovery 响应 MAY 返回（非穷尽）：
- 一个更合适的 **Selfware**（完整解决方案文件/模板）
- 一个或多个 **Skills**（可复用工作流）
- **代码片段** / 补丁建议
- 其它可被 Agent 消费的内容（规则片段、视图模板、配置建议等）

Discovery 触发点（实现 SHOULD；但 MUST 支持用户主动触发）：
1. **On Start**：每次运行时启动后
2. **On Explicit Update Intent**：用户/Agent 明确请求 `update`
3. **On Missing Capability**：执行 intent 缺少扩展/规则
4. **On Error Recovery**：扩展/规则失败需要替代或降级
5. **On User Request**：用户显式点击/输入 “Discover/Check Updates”

---

## 6. Official Protocol Source & Updates（官网协议源与更新）

### 6.1 Protocol Source（官网协议源）

本文件 MAY 声明一个“官网协议源”（仅用于检查更新，不代表自动覆盖权威）：
- `Protocol Source: https://floatboat.ai/selfware.md`
- `Protocol Source (GitHub): https://github.com/floatboatai/selfware`

---

### 6.2 Update Check（更新检查）

若启用官网协议更新检查，运行时 MUST 在以下时机之一触发检查：
- **On Start**（每次运行时）或
- **On User Request**（用户主动要求）

检查 SHOULD 使用 ETag/Last‑Modified 或内容哈希；本 demo 用 `/api/check_update` 提供检查与 diff 摘要。

---

### 6.3 No Silent Apply（禁止静默更新）

一旦检测到官网协议源有更新，运行时 MUST：
1. 告知用户“更新逻辑”（从哪里拉取、如何比对、如何应用、如何回滚点）
2. 告知用户“更新内容摘要”（至少 title + summary；若可用提供 changelog/diff）
3. 让用户确认（Accept/Reject/Defer）
4. 仅在 Accept 后应用更新；Reject MUST 保持当前版本可继续运行

---

## 7. Local Versioning (Git)（本地版本管理）

Selfware 本地文件 **SHOULD** 使用 Git 做版本管理（本地仓库即可；remote 可选）：
- 每次应用更新（无论来源是官网、Discovery、或协作后端）前，运行时 SHOULD 创建一个可回滚点（优先：Git commit/tag；否则：备份文件）。
- 任何“自动拉取/合并 remote”的行为 MUST 走 6.3 的用户确认流程。

---

## 8. Collaboration (Git / Custom)（协作）

除本地版本管理外，Selfware MAY 配置协作后端用于多人协作与同步。协作后端不改变协议文件（`selfware.md`）的定义：它是协议权威文本；协作与同步的写入落点是 `content/` 下的文档数据。

### 8.1 Git Collaboration（Git 协作）

本地项目（尤其是 `content/` 下的实例数据）可以由 Git 承载协作（remote 可选，例如 GitHub）：
- `Collaboration: git`
- `Remote: <git remote url>`
- `Ref: <branch|tag|commit>`（可选，默认 `main`/`master` 由实现决定）

若启用 Git 协作，运行时 MUST：
1. 在 **On Start** 或 **On User Request** 时检查 remote 是否有更新（实现 MAY 只做其中一种，但 MUST 支持用户主动触发）。
2. 一旦检测到更新，必须走 **6.3 No Silent Apply** 的流程（告知更新逻辑 + 内容摘要 + 用户确认）后才能拉取/合并。
3. 合并前 MUST 创建可回滚点（优先 Git commit/tag；否则备份文件）。
4. 冲突出现时 MUST 暂停自动应用，转为让用户确认解决策略（手工/辅助合并/放弃）。

### 8.2 Custom Collaboration（自定义协作服务）

Selfware MAY 使用自定义协作服务：
- `Collaboration: custom`
- `Endpoint: <service url>`

无论协作服务形态如何：
- 写入边界必须保持：只写 `content/`（或 `content/` 下被允许写入的具体文件集合）
- 任何会改变本地 `selfware.md` 的同步/合并，都 MUST 先经过用户确认与告知（同 6.3）

---

## 9. Packaging（`.self` 容器）

### 9.1 Container Format（格式层）

一个 `.self` 文件 MUST 是一个 **ZIP 容器**（为兼容性优先；允许被通用 unzip 工具解包）。

`.self` 容器内 MUST 包含一个固定路径的清单文件：
- `self/manifest.md`

`self/manifest.md` MUST 至少包含：
- `Selfware-Container: zip`
- `Selfware-Container-Version: 1`
- `Protocol-Source: https://floatboat.ai/selfware.md`（示例；可替换）
- `Local-Protocol-Path: selfware.md`
- `Canonical-Data-Scope: content/`

说明：
- 本协议允许未来扩展新的容器类型或版本；实现 MUST 以 `Selfware-Container-Version` 做兼容处理或明确报错。

---

### 9.2 Pack Policy（策略层）

打包（pack）是把一个 Selfware 项目目录写入 `.self` 容器的动作。实现 MUST：
1. **声明打包范围**：提供 include / exclude 规则（glob 或路径列表），并明确 required 的最小集合。
2. **用户确认**：在写出 `.self` 前 MUST 向用户展示：
   - 最终将被包含的文件列表（或树）与总大小
   - 排除规则摘要（以及被排除的关键项）
   - 输出目标路径（`*.self`）
   并让用户 Accept/Reject。
3. **写入边界**：打包动作 MUST NOT 修改协议文件 `selfware.md`；若需要生成容器内的 `self/manifest.md`，应当在容器内生成，不写回本地仓库（除非用户明确要求）。

默认排除（实现 SHOULD 作为安全基线，实例 MAY 覆盖/追加）：
- `.DS_Store`
- `__pycache__/`, `*.pyc`
- `node_modules/`, `.venv/`
- `dist/`, `build/`
- `output/`, `*.log`, `*.tmp`
- `.git/`（除非用户明确要求包含）

---

### 9.3 Pack Plan Placement（落点）

打包协议（格式层 + 策略层）由本文件定义。

实例的“打包计划（pack plan）” SHOULD 放在实例自描述文件中（例如 `manifest.md` 或 Canonical Data 内的专用段落），以便：
- 不绑死仓库结构
- 允许不同 Selfware 实例声明不同的 include/exclude/required

本 demo 的 pack plan 放在 `manifest.md`（运行时清单）中。

---

### 9.4 Sharing（分享/分发）

若要分享一个 Selfware 项目，SHOULD 将整个项目目录打包为一个 ZIP，并将文件名后缀命名为 `.self`（例如 `my_project.self`）。

好处：你分享出去的是一个“活的文档/活的软件”。如果接收方是被信任的协作者，并且在你的许可边界内拥有协作后端访问权限（例如对你的 GitHub 仓库有访问权限），那么当他打开 Selfware 时，可以按本协议的更新规则自动检查更新，并在用户确认后拉取/合并，从而持续与最新版本对齐。

---

## 10. Memory (Optional)（记忆模块，可选）

Memory 是 Selfware 实例在 `content/` 内维护的一组**可审计上下文文件**，用于：
- 记录对话、决策、变更与运行轨迹
- 支持协作与回溯（包括人类与 Agent）
- 在用户许可下，为 Discovery / 更新决策提供最小必要上下文

Memory MUST NOT 成为协议权威源；协议权威源是根目录 `selfware.md`。

### 10.1 Placement（落点）

若启用 Memory，实例 SHOULD 使用目录：
- `content/memory/`

实现 MAY 使用单文件（例如 `content/memory.md`），但多文件结构更利于权限拆分与最小化授权。

### 10.2 File Self‑Description（每个文件必须自描述）

Memory 中的每个文件 MUST 在文件顶部包含一段元信息（Metadata），用于说明“我是谁/我记录什么/如何更新”。

元信息格式（两种任选其一）：
1) YAML front matter（推荐，仍是 Markdown）：
```yaml
---
selfware:
  role: memory_chat | memory_changes | memory_decisions | memory_runs | custom
  title: "..."
  purpose: "..."
  scope: "what is included / excluded"
  update_policy: "append_only | editable | generated"
  owner: "user | team | agent"
  created_at: "YYYY-MM-DDThh:mm:ssZ"
  updated_at: "YYYY-MM-DDThh:mm:ssZ"
---
```
2) `## Meta` 段落（字段同上，键值对形式）。

### 10.3 Change Metadata（任何变更必须写清楚元数据）

对实例中任意文件的变更（包括 `content/`、`views/`、`server.py`、`manifest.md` 等），实现 MUST 记录一条“变更元数据”（Change Record）到 `content/memory/changes.md`（或等价位置）。

每条 Change Record MUST 至少包含：
- `id`（唯一）
- `timestamp`
- `actor`（user / agent / service）
- `intent`
- `paths`（受影响文件列表）
- `summary`（人类可读）
- `rollback_hint`（如何回滚：git ref / backup / manual steps）

当本地启用 Git 版本管理时，`rollback_hint` SHOULD 指向一个可执行的 Git 回滚点（commit/tag/ref），以便将变更记录与实际回滚路径对应起来。

### 10.4 Discovery Consent & Minimization（许可与最小化）

当 Discovery 携带上下文时，Memory MAY 被选择性引用，但 MUST：
- 在用户明确许可下发送
- 默认只发送最小必要片段（例如只发送 decision/change 摘要，不发送 runs/logs 全量）
- 支持用户逐项勾选（或等价确认机制）

---

## 11. Ecosystem (Optional)（生态模块，可选）

Selfware 生态的目标：让一个实例中沉淀的 know‑how（最佳实践、工作流、模板、补丁）能被他人 **发现、复用、演进**，且不引入任何单一主体对“软件定义权”的再次垄断。

本章定义“可被发现的工件（Artifacts）”的最小形状，以及发布/消费的边界与确认流程。它不强制任何 `.self` 实例的内部目录结构；目录约定仅适用于生态仓库（见 11.4）。

### 11.1 Artifact Types（工件类型）

生态工件至少包括（非穷尽）：
- `practice`：规则/最佳实践（触发点、检查方法、修复建议）
- `skill`：可执行工作流（安装/触发/输入输出/安全边界）
- `selfware`：模板/完整实例（可复制、可运行）
- `patch`：补丁/迁移脚本（针对特定版本/结构）

### 11.2 Artifact Metadata（工件元信息，MUST）

任何将被发布或被 Discovery 返回的工件 MUST 自描述元信息（建议 YAML front matter，仍为 Markdown）。

最小字段（MUST）：
- `type`：`practice|skill|selfware|patch`
- `id`：全局唯一（建议带命名空间，例如 `floatboat.practice.pack.confirmation.v1`）
- `version`
- `protocol_version_range`：适配的 Selfware 协议版本范围
- `applies_to`：适用范围/平台/运行时（例如 `generic` / `python_runtime` / `zip_container`）
- `license`
- `sha256`：内容校验哈希（用于拉取/更新/协作时的可验证性）
- `provenance`：来源（从哪些 change/decision/issue 提炼；可附 hash）
- `distribution`：分发信息（可多条：托管地址、索引指针、git url+ref 等）

可选字段（MAY）：
- `trust`：签名/发布者/校验信息（不强制，但实现 SHOULD 支持利用它做本地信任策略）

`distribution` 的基本约束（MUST）：
- MUST 至少包含 1 条可解析的“获取线索”（例如 URL 或 `git:` 指针）
- MUST 允许人类直接读懂（自由文本），但 SHOULD 遵循可机器提取的前缀约定（见下）

`distribution` 推荐前缀约定（SHOULD；自由文本为主）：
- `hosted:` 托管内容地址（例如 Floatboat 托管）
- `index:` 索引条目地址（可指向多个来源）
- `git:` 去中心化指针（例如 `repo#ref=...:path=...`）
- `sha256:` 明示校验哈希（与元信息字段 `sha256` 一致）

`sha256` 计算规则（基本约束，MUST）：
- `sha256` MUST 是对“可被获取并应用的工件内容”的 SHA‑256（十六进制小写）。
- 若工件以托管原文形式分发：对其 UTF‑8 字节序列计算（不做隐式改写）。
- 若工件以 zip/二进制容器分发：对容器字节序列计算。

### 11.3 Publish & Consume（发布与消费边界）

发布（publish）：
- 将本地 know‑how 推送到任意发布端（例如 Floatboat 托管/索引、GitHub 或自建 Git）前，运行时 MUST 获得用户确认。
- 发布行为 MUST 写 Change Record（见 10.3），并明确发布到哪里、以何种形态（托管/索引）、以及回滚策略。

消费（consume）：
- Discovery MUST 返回“候选工件列表 + 元信息”，不得静默应用或替用户决策。
- 运行时/Agent MUST 在本地由一级用户或其代理做选择，并走 **6.3 No Silent Apply**（逻辑 + 摘要/diff + 回滚点 + 用户确认）。

### 11.4 Ecosystem Repos Convention（生态仓库目录约定，SHOULD）

为便于去中心化生态建设与索引扫描，生态仓库 SHOULD 使用顶层目录：
- `selfware/`
- `skills/`
- `practices/`

说明：
- 此约定适用于“生态仓库”（用于发布/分享工件的仓库），不强制普通 `.self` 实例的内部结构。

---

## 12. Self‑Analysis (Optional)（自分析模块，可选）

Self‑Analysis 是一个可选模块，用于从一个 Selfware 实例的“进展与变更”中提炼 know‑how，并在用户许可下与 Discovery/生态发布形成进化闭环。

本章只定义 Self‑Analysis 的协议边界与输出形状；实现细节（脚本、模型、运行环境）属于运行时，可替换。

### 12.1 Inputs（输入）

Self‑Analysis MAY 读取（非穷尽）：
- Canonical Data（例如 `content/selfware_demo.md`）
- `content/memory/changes.md`、`content/memory/decisions.md` 等 Memory 文件（若启用）
- `manifest.md`（pack plan、运行时约定）
- 运行时文件（例如 `server.py`、`views/`）用于一致性/边界扫描

Self‑Analysis MUST 遵守写入边界：不得绕过协议写入 `selfware.md`；任何写入均应落在实例允许的范围（本 demo 为 `content/`）。

### 12.2 Outputs（输出，MUST 文件化）

Self‑Analysis 的输出 MUST 以文件形式落地，并可审计/可回滚。输出 MAY 包括：
- insights（分析结论与可执行建议）
- practices/skills/selfware/patch 的草稿（用于生态发布前的本地审阅）
- discovery request draft（将要发送的 intent + minimal context 草案）
- publish queue（待发布工件清单，含 `sha256` 与 `distribution` 草案）

任何输出写入 MUST 记录 Change Record（见 10.3）。

### 12.3 Consent & Loop（许可与闭环）

Self‑Analysis 可能触发 Discovery 或生态发布，但 MUST：
- 在向任何外部端点发送内容前，获得用户明确许可
- 默认只发送最小必要上下文（并允许用户勾选/裁剪）
- 在接收候选工件后，应用更新必须走 **6.3 No Silent Apply**

### 12.4 Trigger Freedom（触发自由）

Self‑Analysis 的触发点由运行时/Agent 自由决定（例如 On Start、On User Request、On Significant Change 等）。协议只要求：
- MUST 支持用户显式触发
- MUST 记录关键动作的变更元数据与回滚点（通过 Change Record）

---

## Non‑Normative（非规范性）

本仓库的 `views/`、`server.py`、`assets/`、`skills/` 仅用于演示“同一份 Markdown 被多视图投影 + 可保存”的最小闭环。

`content/` 目录在本仓库中是 **demo instance data**（示例实例数据/夹具/实验材料），作为实例的 Canonical Data 写入范围；但它不作为协议权威源（协议权威源是根目录的 `selfware.md`）。

英文版：`selfware.md`。
