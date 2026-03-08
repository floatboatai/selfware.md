# Selfware

> A file is an app. Everything is a file.

Selfware 是 Agent 时代的文件哲学：让文件回归用户，永不失效，无限进化。

Version: 0.2.0 (Draft)

License: MIT — you MAY modify, redistribute, and create derivatives.

本文使用 RFC 风格术语：**MUST / MUST NOT / SHOULD / SHOULD NOT / MAY**。

---

## 1. 数据主权（Data Sovereignty）

**"文件属于用户，而非应用。"**

传统软件将数据锁在专有格式与云端黑箱中，用户名义上拥有数据，实际上被供应商绑架。Selfware 拒绝这种模式：用户的数据永远在用户手里。

### 不可违反的原则

- 用户数据（Canonical Data）MUST 始终存在于用户可访问、可读取、可迁移的位置。
- 任何对用户数据的变更 MUST 经用户确认后才能生效（No Silent Apply）。
- 任何变更 MUST 可回滚——用户拥有撤销一切的权利。
- 运行时、视图、逻辑均为可替换的实现；它们 MUST NOT 成为数据的唯一持有者或访问瓶颈。
- 远程同步 MUST NOT 在未经用户许可的情况下静默修改本地数据。

---

## 2. 自包含（Self-Containment）

**"一个文件就是一个完整的软件。"**

Selfware 的分发单元（单文件或 `.self` 包）可以同时包含数据、逻辑和视图。这不是技术上的好奇，而是一种权力结构的变革：当所有构成要素都在同一个用户可持有的单元中，任何中心化平台都无法成为瓶颈。

### 不可违反的原则

- 一个 Selfware 实例 MUST 能作为独立单元被复制、传输和运行，不依赖特定平台或服务。
- 视图是数据的函数（`View = f(Data, Intent, Rules)`）；视图 MUST NOT 成为数据真理源。
- 运行时（Kernel、Views、Skills 等）是可替换的；任何 Agent SHOULD 能根据协议重新生成逻辑和视图。
- 打包（`.self`）MUST 使用通用格式（ZIP），确保任何人都能解包查看内容。
- 实例的开发过程（任务、决策、变更记录）SHOULD 记录在实例内部，使其迭代历史可审计、可回溯，不依赖外部工具。

---

## 3. 去中心化进化（Decentralized Evolution）

**"文件自己会进化，不依赖中心。"**

Selfware 实例不是静态快照，而是活的实体。它可以发现更好的方案、提炼自身经验、与其他实例交换 know-how——全部在用户许可下完成，无需任何中心化平台作为中介。

### 不可违反的原则

- 实例 MAY 通过 Discovery 机制寻找更好的解决方案（Skills、Practices、模板等），但发送任何上下文信息 MUST 经用户明确许可。
- 实例 MAY 通过 Self-Analysis 从自身变更中提炼 know-how，但发布到外部 MUST 经用户确认。
- 生态工件（Artifacts）MUST 自描述（携带元信息），以支持去中心化发现和验证。
- 协议本身是 MIT 许可的：任何人 MAY 修改、分发、演进。没有任何单一主体可以垄断软件定义权。
- 协作（多人同步、版本管理）SHOULD 基于开放协议（如 Git），而非专有服务。

---

## Specifications

本文档只定义哲学与不可违反的原则。所有实现细节、API 格式、字段定义、目录约定等规范，请参阅 `specs/` 目录：

| Spec | 内容 |
|------|------|
| [specs/runtime-api.md](specs/runtime-api.md) | 运行时接口、能力声明 |
| [specs/packaging.md](specs/packaging.md) | `.self` 容器格式与打包策略 |
| [specs/memory.md](specs/memory.md) | 记忆模块格式与变更记录 |
| [specs/ecosystem.md](specs/ecosystem.md) | 生态工件元信息与发布/消费 |
| [specs/collaboration.md](specs/collaboration.md) | 版本管理与协作规范 |
| [specs/process.md](specs/process.md) | 开发过程记录（任务、决策、变更） |

## Guides

| Guide | 内容 |
|-------|------|
| [guides/adoption.md](guides/adoption.md) | 采纳指南：让已有项目符合 Selfware 规范 |
| [guides/import-history.md](guides/import-history.md) | 历史迁移指南：从 Git 导入变更记录 |
