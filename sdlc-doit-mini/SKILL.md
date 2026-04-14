---
name: sdlc-doit-mini
description: >-
  Run a lightweight SDLC workflow for micro changes such as style tweaks,
  copy edits, or small UI fixes. Keeps minimal iteration artifacts and final
  browser acceptance without allowing architecture drift.
argument-hint: "小任务描述"
homepage: https://github.com/evan-taojiangcb/sdlc-workflow
---

# /sdlc-doit-mini

小任务入口，适合微小改动。

## 使用方式

先阅读：

- `../sdlc-workflow/references/micro-change-mode.md`
- `../sdlc-workflow/references/mini-pipeline.md`
- `../sdlc-workflow/references/pipeline-overview.md`
- `../sdlc-workflow/references/tg-notifier.md`

## 规则

1. 项目必须已完成 `/sdlc-init`
2. 需求必须满足 mini 条件；不满足则升级到 `/sdlc-doit`
3. 即使是 mini，也必须生成：
   - `requirements.md`
   - `design.md`
   - `tasks.md`
4. `design.md` 必须明确声明：`无架构变更`
5. 在 iteration 产物完成前，不得直接编辑业务代码
6. 在业务代码修改前，必须先执行 mini Gate 1
7. `tasks.md` 完成后必须回写勾选状态
8. 实现后必须先做 validation capability detection，确认 lint / unit / Playwright / Playwright MCP / CDP 的可用性
9. validation capability detection 完成后，必须执行 mini Gate 2
10. `TEST_BOOTSTRAP_POLICY` 决定缺少测试基础设施时的行为；existing project 默认推荐 `report`
11. OpenClaw / 远程场景不要依赖交互式 ask，优先输出报告和 TG 通知
12. Playwright 只作为预检
13. 最终通过依据必须是：
    - Playwright MCP
    - CDP
14. 必须生成 mini 最终报告，记录 Gate、验证能力检测和 MCP 验收结果

## TG 通知要求

**mini 模式同样要求关键环节发送 TG 通知**，详见 `../sdlc-workflow/references/mini-pipeline.md` 中每个 Step 的通知定义。

至少覆盖以下通知点：

1. 📥 mini 需求已收录
2. 🔍 mini Gate 1 结果
3. 🔨 mini 开始实现
4. 🔍 mini Gate 2 结果
5. 🧪 mini 验收结果
6. ✅ mini 迭代完成
7. ⚠️ 循环超限（Gate 2 超限时触发）

通知失败不阻塞流程（只 log）。

## 何时自动升级

若出现以下任一情况，立即切换到 `/sdlc-doit`：

- 影响文件超过 3 个
- 需要改 API
- 需要改数据模型
- 需要改目录结构
- 需要新增 workspace
