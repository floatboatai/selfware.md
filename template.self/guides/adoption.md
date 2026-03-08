> Guide for: [selfware.md](../selfware.md)

# 采纳指南：让已有项目符合 Selfware 规范

本指南帮助你将一个已有项目逐步转化为 Selfware 实例。每一步独立可用——即使只完成 Step 1，项目也已具备最小合规性。

---

## Step 0: 评估（Assess）

在动手之前，先识别项目中的两类内容：

| 类型 | 定义 | 示例 |
|------|------|------|
| **Canonical Data** | 用户拥有的、不可替代的数据 | 文章、笔记、配置、用户创建的资产 |
| **Runtime** | 可替换的逻辑/视图/工具 | 构建脚本、UI 组件、服务端代码 |

**检查清单：**
- [ ] 列出所有 canonical data 文件/目录
- [ ] 列出所有 runtime 文件/目录
- [ ] 确认没有用户数据被硬编码在 runtime 代码中

---

## Step 1: 最小合规（Minimal Conformance）

**目标：** 项目具备 selfware 身份和数据边界。

1. 在项目根目录创建 `selfware.md`（可复制 [模板](../selfware.md)）
2. 创建 `content/` 目录，将 Step 0 识别的 canonical data 移入
3. 创建 `manifest.md`，至少声明以下字段：
   ```
   Manifest-Version: 1
   Instance-Id: your-project-name
   Local-Protocol-Path: selfware.md
   Canonical-Data-Scope: content/
   ```

**检查清单：**
- [ ] `selfware.md` 存在且包含协议版本
- [ ] `content/` 目录包含所有用户数据
- [ ] `manifest.md` 声明了 `Canonical-Data-Scope`

---

## Step 2: 过程记录（Process Recording）

**目标：** 项目具备变更追踪能力。

1. 创建目录结构：
   ```
   process/
   ├── tasks/      # 任务记录
   ├── decisions/  # 决策记录
   └── runs/       # 运行日志
   ```
2. 创建 `content/memory/changes.md`，格式参考 [specs/memory.md](../specs/memory.md)
3. （可选）从 git log 导入历史变更记录，参见 [历史迁移指南](import-history.md)

**检查清单：**
- [ ] `process/` 三个子目录已创建
- [ ] `content/memory/changes.md` 存在且格式正确

---

## Step 3: 运行时分离（Runtime Separation）

**目标：** 逻辑与数据解耦，满足 `View = f(Data)` 原则。

1. 创建 `runtime/` 目录
2. 将所有逻辑/视图/服务代码移入 `runtime/`
3. 创建 `runtime/capabilities.yaml` 声明运行时能力
4. 确保 runtime 代码从 `content/` 读取数据，不硬编码任何用户数据

**检查清单：**
- [ ] runtime 代码全部位于 `runtime/`
- [ ] `runtime/capabilities.yaml` 已声明
- [ ] 视图/逻辑中无硬编码的用户数据

---

## Step 4: 可选增强（Optional Enhancements）

根据需要添加：

| 增强项 | 操作 | 参考 |
|--------|------|------|
| 治理 | 创建 `governance/file-contract.yaml` 和 `trust-policy.yaml` | [模板](../governance/file-contract.yaml) |
| 规范 | 在 `specs/` 中添加项目特定规范 | [specs/](../specs/) |
| 打包 | 配置 `.self` 打包（manifest 的 Pack Include/Exclude） | [specs/packaging.md](../specs/packaging.md) |
| Agent 协作 | 创建 `AGENT_CHARTER.md`、`AGENTS.md`、`CLAUDE.md` | [模板目录](../) |

**检查清单：**
- [ ] （如需）治理文件已创建
- [ ] （如需）`.self` 打包配置已完成并可正常打包
