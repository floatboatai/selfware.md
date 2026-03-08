> Guide for: [selfware.md](../selfware.md)

# Git 历史迁移指南 / Import History Guide

将已有项目�� git 历史迁移到 selfware 实例。

---

## 方案 A：保留完��历史 (Keep Full History)

直接���现有 repo 上套 selfware 结构，所有 commit 原样保留。

```bash
cd your-project
cp -r /path/to/template.self/* .          # 复制 selfware 模板结构
git add selfware.md specs/ content/ governance/ runtime/
git commit -m "feat: initialize selfware structure"
```

优点：历史完整，`git log` / `git blame` 可用。适用于长期维护、需要追��的项目。

---

## 方案 B：压缩历史到 changes.md (Squash into Change Records)

从 git log 提取关键 commit 写入 `content/memory/changes.md`，以全新 repo 开始。

```bash
git log --oneline --no-merges > /tmp/history.txt   # 导出旧 commit 摘要
mkdir my-instance && cd my-instance
cp -r /path/to/template.self/* .
git init && git add -A && git commit -m "init: selfware instance"
# 然后将旧历史追加到 content/memory/changes.md（格式如下）
```

Change Record 格式（遵循 [specs/memory.md](../specs/memory.md)）：

```markdown
## CHG-IMPORT-001
- timestamp: 2025-01-15T00:00:00Z
- actor: user
- intent: import_legacy_history
- paths: [entire project]
- summary: 从旧仓库导入 142 条 commit 摘要。
- rollback_hint: 此为初始导入，无需回滚。
```

适用于轻量起步、不需要 `git blame` 的场景。

---

## 方案 C：混合方式 (Hybrid) — 推荐

保留 git 历史 + 把里程碑 commit 同步到 changes.md。

```bash
cd your-project
cp -r /path/to/template.self/* .                    # 套入 selfware 结构
git log --oneline --decorate=short \
  --simplify-by-decoration | head -20 \
  > /tmp/milestones.txt                              # 提取里程碑 commit
# 将每条里程碑写入 changes.md，intent 设为 milestone_import
git add -A
git commit -m "feat: initialize selfware with milestone records"
```

���顾完整 `git log` 与 Agent 可读的 changes.md 项目脉络。

---

## 注意事项

- 所有变更 MUST 记录到 `content/memory/changes.md`（[specs/memory.md](../specs/memory.md)）。
- 重要操作前 SHOULD 创建 rollback point（[specs/collaboration.md](../specs/collaboration.md)）。
- 导��完成后建议运行 `verify-artifact` 确认实例完整性。
