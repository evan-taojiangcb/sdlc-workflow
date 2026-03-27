---
name: sdlc-doit
description: >-
  Run the full SDLC workflow for normal feature or fix work on an initialized
  project. Uses ordered iterations, dual Codex review gates, tests, docs
  updates, and git delivery.
argument-hint: "需求描述 | file:///path | https://jira.xxx/PROJ-123"
homepage: https://github.com/<org>/sdlc-workflow
---

# /sdlc-doit

标准需求入口，跑完整 SDLC 流程。

## 使用方式

先阅读共享主流程：

- `../sdlc-workflow/SKILL.md`
- `../sdlc-workflow/references/pipeline-overview.md`

## 规则

1. 项目必须已完成 `/sdlc-init`
2. 若 baseline 缺失，先回退执行 `/sdlc-init`
3. 走完整流程：
   - requirements
   - clarifier
   - design
   - tasks
   - Gate 1
   - implement
   - test generation
   - Gate 2
   - test pipeline
   - docs update
   - git commit
4. 最终通过依据仍为：
   - Chrome DevTools MCP
   - WebMCP

## 何时不要用

若需求只是小型 UI 调整或单点微变更，优先使用 `/sdlc-doit-mini`。
