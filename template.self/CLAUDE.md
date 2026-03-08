# CLAUDE

All agents operating in this instance MUST follow:
- `AGENT_CHARTER.md` — 权威原则（必读）
- `governance/file-contract.yaml` — 文件权限合约
- `docs/goal.txt` — 当前目标

---

## Selfware 三原则速查

1. **数据主权** — 用户数据只在 `content/`，变更必须用户确认且可回滚
2. **自包含** — 数据+逻辑+视图在同一单元，运行时可替换，过程记录在实例内部
3. **去中心化进化** — Discovery/Self-Analysis/Ecosystem 均需用户许可，无中心依赖

完整定义见 `selfware-zh.md` / `selfware.md`。

---

## 文件地图

```
selfware-zh.md / selfware.md   ← 协议权威（哲学+原则，require_discussion）
manifest.md                     ← 实例清单（canonical scope, pack plan）
content/                        ← 用户数据写入范围（agent_write: allow）
  memory/changes.md             ← 变更审计日志（append-only, agent_write: allow）
process/
  tasks/                        ← 任务记录（require_discussion）
  decisions/                    ← 决策记录（require_discussion）
  runs/                         ← 运行日志（agent_write: allow）
runtime/                        ← 可替换的运行时代码
specs/                          ← 实现规范（runtime-api, packaging, memory, ecosystem, collaboration, process）
guides/                         ← 操作指南（adoption, import-history）
governance/                     ← 治理文件（require_discussion）
entrypoint/                     ← 人机交互入口（require_discussion）
```

---

## 写入规则

| 范围 | 权限 | 说明 |
|------|------|------|
| `content/**` | **可直接写** | 用户数据和记忆，canonical data scope |
| `content/memory/changes.md` | **可直接追加** | 每次 material change 必须写 Change Record |
| `process/runs/**` | **可直接写** | 运行日志 |
| `process/tasks/**`, `process/decisions/**` | 需讨论 | 任务和决策需人类对齐 |
| `selfware*.md`, `governance/**`, `entrypoint/**`, `runtime/**` | 需讨论 | 高影响文件 |
| `.env*` | **禁止** | 人类专属 |

---

## 常见工作流

### 修改用户数据
1. 写入 `content/` 下的目标文件
2. 追加 Change Record 到 `content/memory/changes.md`（格式见 `specs/memory.md`）
3. 如有 git，确保变更可回滚

### 开发新功能 / 修 Bug
1. 读 `docs/goal.txt` 确认与当前目标一致
2. 在 `process/tasks/` 创建任务记录（需讨论）
3. 实施变更，遵守写入边界
4. 追加 Change Record
5. 关键决策写入 `process/decisions/`

### 初始化环境
1. 检查 `manifest.md` 中的 `Runtime-Lang` 和 `Deps-File`
2. 创建隔离环境（Python 用 uv venv，Node 用 pnpm）
3. 安装依赖（优先用锁文件）
4. 验证入口可执行后再启动
5. 脚本必须同时提供 `.ps1` 和 `.sh` 版本，功能对等。见 `specs/runtime-api.md` §1.5
6. 详见 `specs/runtime-api.md` §1

### 导入已有项目
→ 参照 `guides/adoption.md`（分步采纳）和 `guides/import-history.md`（Git 历史迁移）

### 运行时变更
1. 修改 `runtime/` 下的代码（需讨论）
2. 确保视图仍是数据的函数 `View = f(Data, Intent, Rules)`
3. 视图 MUST NOT 硬编码 canonical data
4. 视图规范见 `specs/runtime-api.md` §4

### 为项目生成/迁移视图
- **已有 UI**：保留原有全部功能，数据流改为走 Runtime API，功能集 MUST NOT 缩减
- **CLI / 无 UI**：每个命令映射为可操作区域，按用户意图组织，输出结构化呈现
- 所有数据变更场景（保存、更新、打包、Discovery、发布）MUST 提供确认界面

### 打包为 .self
→ 参照 `specs/packaging.md`，打包前 MUST 展示文件列表并获用户确认

### Discovery / 对外通信
→ 发送任何上下文 MUST 经用户明确许可，默认只发最小必要信息
