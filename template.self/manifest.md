# Selfware Instance Manifest
Manifest-Version: 1
Instance-Id: template.self
Title: Selfware Runnable Template
Protocol-Source: https://github.com/floatboatai/selfware.md
Update-Default-Source: https://raw.githubusercontent.com/floatboatai/selfware.md/main/template.self/selfware.md
Local-Protocol-Path: selfware.md
Canonical-Data-Scope: content/
Runtime-Entry: runtime/server.py
Runtime-Lang: python>=3.10
Deps-File: runtime/requirements.txt
Deps-Lock: runtime/uv.lock
Capabilities-File: runtime/capabilities.yaml
Trust-Policy-File: governance/trust-policy.yaml
Collaboration: local
No-Silent-Apply: required

## Pack Include
- AGENT_CHARTER.md
- AGENTS.md
- CLAUDE.md
- docs/**
- entrypoint/**
- governance/**
- runtime/**
- specs/**
- skills/**
- process/tasks/**
- process/decisions/**
- process/runs/.gitkeep
- content/**
- manifest.md
- selfware.md
- selfware-zh.md

## Pack Exclude
- .git/**
- .gitignore
- .DS_Store
- __pycache__/**
- *.pyc
- node_modules/**
- .venv/**
- dist/**
- build/**
- output/**
- *.log
- *.tmp

## Pack Required
- AGENT_CHARTER.md
- AGENTS.md
- CLAUDE.md
- manifest.md
- selfware.md
- selfware-zh.md
- governance/file-contract.yaml
- runtime/capabilities.yaml
- entrypoint/index.yaml
- content/selfware_demo.md
- content/memory/changes.md
