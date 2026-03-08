> Parent: [selfware.md](../selfware.md)

# Runtime API Specification

Version: 0.2.0 (Draft)

---

## 1. Initialization（环境初始化）

运行实例前，runtime MUST 确保所有依赖已就绪。

### 1.1 依赖声明

实例 MUST 在 `manifest.md` 中声明运行时依赖：

- `Runtime-Lang`: 运行时语言及最低版本（如 `python>=3.10`, `node>=18`）
- `Deps-File`: 依赖清单文件路径（如 `runtime/requirements.txt`, `runtime/package.json`）
- `Deps-Lock`: 可选，锁文件路径（如 `runtime/uv.lock`, `runtime/pnpm-lock.yaml`）

### 1.2 初始化流程

启动脚本（`entrypoint/scripts/run-app.*`）MUST 在启动服务前执行以下步骤：

1. **检测运行时**：确认语言环境可用（python/node/etc），不可用则报错并给出安装提示
2. **创建隔离环境**（SHOULD）：Python 用 venv/uv，Node 用 node_modules，避免污染全局
3. **安装依赖**：根据 `Deps-File` 安装（优先使用锁文件保证可复现）
4. **验证就绪**：确认入口文件可执行后再启动服务

### 1.3 包管理器约定

| 语言 | 推荐管理器 | 依赖文件 | 锁文件 |
|------|-----------|---------|--------|
| Python | uv | `requirements.txt` 或 `pyproject.toml` | `uv.lock` |
| Node.js | pnpm | `package.json` | `pnpm-lock.yaml` |

实例 MAY 使用其他包管理器，但 MUST 在 `manifest.md` 中注明。

### 1.5 Cross-Platform（跨平台）

- 入口脚本 MUST 同时提供 `.ps1`（Windows/PowerShell）和 `.sh`（Linux/macOS/Bash）版本，功能对等。
- `manifest.md` 及协���文件中的路径 MUST 使用正斜杠 `/`；脚本内部 SHOULD 使用各平台原生风格。
- 环境检测失败时 MUST 给出��晰的错误信息和安装提示（如缺少 Python 时应指出版本要求和安装方式）。
- Python venv 激活路径：Windows 为 `Scripts/`，POSIX 为 `bin/`。脚本 MUST 根据当前平台选择正确路径。
- `entrypoint/index.yaml` 中 `action` 字段引用脚本时，SHOULD 同时列出两个平台版本或使用不含扩展名的逻辑名。

### 1.4 离线与打包

`.self` 包 MAY 内嵌依赖（vendor）以支持离线运行。若内嵌：
- `manifest.md` SHOULD 声明 `Deps-Vendored: true`
- 安装步骤 SHOULD 优先使用本地 vendor，网络不可用时不应失败

---

## 2. Binding

Kernel MUST bind to loopback only (`localhost/127.0.0.1/::1`) unless the user explicitly configures a wider boundary.

## 2. Core Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/content` | Read Canonical Data |
| `POST` | `/api/save` | Write to Canonical Data (within `content/` scope only) |
| `GET` | `/api/self` | Instance metadata (path, sha256, content) |
| `GET` | `/api/manifest` | Read `manifest.md` |
| `GET` | `/api/capabilities` | Runtime capability declaration (see §3) |
| `GET` | `/api/check_update?url=...` | Check remote protocol source for updates |

### Write Boundary (MUST)

- `POST /api/save` MUST only write within `content/` (canonical data scope).
- Runtime MUST NOT write `selfware.md` unless the user has explicit intent and confirmation.

## 3. Capability Declaration

Runtime MUST declare its capabilities so users and other Agents can understand boundaries.

### Required Fields (MUST)

- `write_scope`: where writes are allowed (e.g., `content/`)
- `confirmation_required`: actions requiring user confirmation (e.g., pack, pull/merge, apply update, publish, send context)
- `endpoints`: available endpoints and their purpose
- `modules`: optional module status (e.g., git/discovery/self-analysis: supported/enabled)

### Carrier (MUST provide at least one)

- **Machine-readable**: e.g., `GET /api/capabilities`
- **Human-readable**: e.g., printed on startup or shown in a UI panel

### Interaction Constraints (MUST)

- If runtime/Agent discovers a capability that is supported but not enabled, missing config, or has multiple strategy branches, it MUST ask the user and obtain explicit confirmation before performing any write or outbound communication.
- Any writes triggered by such prompting MUST still satisfy write scope (`content/`) and Change Record requirements.

---

## 4. Views（视图规范）

### 4.1 核心约束

- `View = f(Data, Intent, Rules)` — 视图是 Canonical Data 的投影，MUST NOT 成为数据真理源。
- 视图属于 runtime，是可替换的；用户或 Agent MAY 重���生成、替换、或切换视图。
- 视图的数据读写 MUST 通过 Runtime API（§2），不得绕过 API 直接操作 `content/`。
- 视图文件 SHOULD 放在 `views/` 目录下，权限为 `require_discussion`。

### 4.2 导入策略

#### 已有 UI 的项目（Web/Desktop/Mobile）

优先保留原有功能和交互体验：

- **功能完整性**：原 UI 的所有用户可操作功能 MUST 在迁移后继续可用。允许实现方式变化（如���端改为走 Runtime API），但用户视角的功能集 MUST NOT 缩减。
- **数据流改造**：将原 UI 的数据读写改为通过 Runtime API（`/api/content`, `/api/save`）。视图不再持有数据状态，只持有渲染状态。
- **渐进迁移**：MAY 分阶段——先保持原 UI 不变仅接入 API，后续再拆分为可替换模块。

#### CLI / 无 UI 的项目

为其生成可视化界面：

- **功能映射**：CLI 的每个命令/子命令 SHOULD 对应视图中的一个可操作区域（按钮、表单、面板）。不得遗漏功能点。
- **信息组织**：按用户意图（而非命令语法）组织。相��功能分组，常用功能突出，高级/危险操作收纳但可达。
- **输出可视化**：CLI 文本输出 SHOULD 结构化呈现（表格、图表、状态指示器），而非原样终端文本。
- **参数暴露**：命令参数 SHOULD 转化为表单控件（输入框、下拉、开关），附默认值和说明。

### 4.3 用户确认流程（No Silent Apply 的视图呈现）

视图 MUST 为以下场景提供确认界面：

| 场景 | 视图 MUST 呈现 |
|------|----------------|
| 数据保存 | 变更摘要（diff/summary），Accept / Reject |
| 远程更新 | 更新来源、内容摘要、回滚方式，Accept / Reject / Defer |
| 打包 .self | 文件列表、总大小、排除项，Accept / Reject |
| Discovery 发送上下文 | 将发送的内容预览、目标端点，Accept / Reject |
| 生态发布 | 发布内容、目标、回滚策略，Accept / Reject |

### 4.4 多视图支持

同一份 Canonical Data MAY 同时拥有多个视图（编辑视图、只读视图、仪表盘等）。

- 视图注册：实例 MAY 在 `manifest.md` 中���明可用视图及其入口��
- 视图切换：runtime SHOULD 提供切换机制（路由、标签���、或用户选择）。
- 数据一致性：��有视图 MUST 从同一 Canonical Data 读取��一个视图的保存 MUST 反映到其他视图。
