---
name: sdlc-init
description: >-
  Initialize or onboard a project into the SDLC workflow. Detects fresh vs
  existing projects, bootstraps workflow files, runs baseline intake for
  existing codebases, and writes minimal workflow config such as TG username
  and review rounds.
argument-hint: '可选: "tg=123456789 review=1 branch=feat/ test-bootstrap=report"'
homepage: https://github.com/evan-taojiangcb/sdlc-workflow
---

# /sdlc-init

只做初始化和接入，不做需求开发。

## 前置条件

使用 TG 通知前，需先配置好 OpenClaw CLI 并获取你的 Telegram 账号 ID：

```bash
npm install -g openclaw    # 安装
openclaw auth login         # 登录
openclaw channel connect telegram  # 绑定 Telegram
openclaw channel info telegram     # 获取你的账号数字 ID
```

## 目标

1. 判断当前项目是 `fresh project` 还是 `existing project`
2. 执行共享初始化脚本：`../sdlc-workflow/scripts/init-project.sh`
3. 若为 existing project，执行：`../sdlc-workflow/references/existing-project-intake.md`
4. 将 prompt 中给出的最少流程参数写入 `.env`

## 可选 prompt

支持自然语言或键值对，优先提取：

- `tg=123456789` — Telegram 账号数字 ID 或 chat_id
- `review=1`
- `branch=feat/`
- `test-bootstrap=report|auto|never`

若 prompt 未给出：

- `TG_USERNAME` 优先尝试从运行时上下文获取
- `REVIEW_MAX_ROUNDS` 默认写为 `1`
- `TEST_BOOTSTRAP_POLICY` 默认：
  - existing project → `report`
  - fresh project → `auto`

## 执行步骤

1. 读取 `../sdlc-workflow/scripts/init-project.sh`
2. 判断项目类型：
   - 若已有 `apps/`、`packages/`、`src/`、`package.json`、`pnpm-workspace.yaml`、`turbo.json`、`.git/` 等工程结构，则视为 existing project
   - 否则视为 fresh project
3. 运行：

```bash
bash ../sdlc-workflow/scripts/init-project.sh .
```

4. 若 prompt 中带有 `tg` / `review` / `branch` / `test-bootstrap`，运行：

```bash
bash ../sdlc-workflow/scripts/update-workflow-config.sh --project-root . --tg <username> --review-rounds <n> --branch-prefix <prefix> --test-bootstrap-policy <policy>
```

5. 若为 existing project，严格按照 `../sdlc-workflow/references/existing-project-intake.md` 生成：
   - `.claude/PROJECT_BASELINE.md`
   - `.claude/EXISTING_STRUCTURE.md`
   - `.claude/TEST_BASELINE.md`

## TG 通知

初始化完成后必须发送 TG 通知（模板详见 `../sdlc-workflow/references/tg-notifier.md`）：

```bash
# fresh project
notify_tg "🚀 项目初始化完成（fresh project）
📂 .claude/CLAUDE.md ✅
📂 docs/ 基础文档 ✅
⚙️ .env 配置已就绪"

# existing project
notify_tg "🚀 项目初始化完成（existing project）
📄 PROJECT_BASELINE.md ✅
📄 EXISTING_STRUCTURE.md ✅
📄 TEST_BASELINE.md ✅
🔒 结构保护规则已生效"
```

通知失败不阻塞流程。

## 输出

- `.claude/CLAUDE.md`
- `.claude/rules/workflow-rules.md`
- `.claude/ARCHITECTURE.md`
- `.claude/SECURITY.md`
- `.claude/CODING_GUIDELINES.md`
- `.env.example`
- `.env`
- existing project 额外 baseline 文档

## 结束条件

输出一段简短总结，至少包含：

1. `fresh` 还是 `existing`
2. 初始化生成了哪些文件
3. 是否已写入 `TG_USERNAME`
4. `REVIEW_MAX_ROUNDS` 当前值
5. `TEST_BOOTSTRAP_POLICY` 当前值
6. TG 通知是否已发送
7. 后续建议使用 `/sdlc-workflow proposal` 还是 `/sdlc-workflow doit` 还是 `/sdlc-workflow mini`
