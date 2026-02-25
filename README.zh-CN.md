# Selfware Protocol Demo

语言： [English](README.md) | **中文** | [Italiano](README.it.md) | [日本語](README.ja.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

本仓库是 **Selfware Protocol** 的 demo 版本，提供中英文协议草案模板。

## 当前内容

- `template.self/selfware-zh.md`：协议草案（中文版）
- `template.self/selfware.md`：协议草案（英文版）

当前协议版本：`v0.1.0 (Draft)`

## Selfware 是什么

Selfware 旨在定义 Agent 时代的统一文件协议：

- A file is an app. Everything is a file.
- 在同一可分发单元（单文件或 `.self` 容器）中，可选整合数据、逻辑、视图。
- 以去中心化方式支持人↔Agent、Agent↔Agent 协作流程。

## 核心原则（摘要）

- **Canonical Data Authority**：每个实例都必须定义内容真理源。
- **Write Scope Boundary**：写入应限制在 `content/`（或声明的等价 canonical 范围）。
- **No Silent Apply**：更新必须先告知并获得用户确认，不能静默应用。
- **View as Function**：`View = f(Data, Intent, Rules)`；视图不是内容真理源。

## 如何使用

快速体验可以尝试这个 Demo：`https://github.com/awesome-selfware/openoffice.self`

1. 阅读中文协议：`template.self/selfware-zh.md`
2. 阅读英文协议：`template.self/selfware.md`
3. 基于模板创建你的实例协议文件，并按需扩展运行时模块（API、打包、协作、Memory、Discovery 等）。

## 仓库说明

- 当前仓库仅包含协议模板文档。
- 不包含完整 runtime/server 实现代码。

## 许可证

协议正文声明为可选 MIT 许可（详见协议文件）。

