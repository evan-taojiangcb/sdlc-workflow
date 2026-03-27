---
name: sdlc-doit
description: >-
  Run the full SDLC workflow for normal feature or fix work on an initialized
  project. Uses ordered iterations, dual Codex review gates, tests, docs
  updates, and git delivery.
argument-hint: "需求描述 | file:///path | https://jira.xxx/PROJ-123"
homepage: https://github.com/evan-taojiangcb/sdlc-workflow
---

# /sdlc-doit

标准需求入口，跑完整 SDLC 流程。

## 使用方式

先阅读共享主流程：

- `../sdlc-workflow/SKILL.md`
- `../sdlc-workflow/references/pipeline-overview.md`
- `../sdlc-workflow/references/tg-notifier.md`

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
4. 进入测试前必须先做 validation capability detection，确认项目现有 lint/unit/Playwright/browser 验收能力
5. `TEST_BOOTSTRAP_POLICY` 决定缺少测试基础设施时的行为；existing project 默认推荐 `report`
6. OpenClaw / 远程场景不要依赖交互式 ask，优先输出报告和 TG 通知
7. 最终通过依据仍为：
   - Chrome DevTools MCP
   - WebMCP

## TG 通知要求

**每个关键环节都必须发送 TG 通知**，完整通知列表见 `../sdlc-workflow/references/tg-notifier.md`。

至少覆盖以下 12 个通知点：

1. 📥 需求已收录
2. ❓ 需求澄清（低置信度时）
3. 🎨 设计文档已生成
4. 📋 任务分解完成
5. 🔍 设计 Review 结果（Gate 1）
6. 🔨 开始实现 / 实现完成
7. 🧪 测试用例已生成
8. 🔍 Code Review 结果（Gate 2）
9. 🧪 测试执行结果
10. 📝 文档已更新
11. ✅ 迭代完成 + PR 链接
12. ⚠️ 循环超限（任何 Gate/测试超限时触发）

通知失败不阻塞流程（只 log）。

## 何时不要用

若需求只是小型 UI 调整或单点微变更，优先使用 `/sdlc-doit-mini`。
