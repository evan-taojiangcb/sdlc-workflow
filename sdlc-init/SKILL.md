---
name: sdlc-init
description: >-
  Initialize or onboard a project into the SDLC workflow. Detects fresh vs
  existing projects, bootstraps workflow files, runs baseline intake for
  existing codebases, and writes minimal workflow config such as TG username
  and review rounds.
argument-hint: '可选: "tg=@evan review=1 branch=feat/"'
homepage: https://github.com/<org>/sdlc-workflow
---

# /sdlc-init

只做初始化和接入，不做需求开发。

## 目标

1. 判断当前项目是 `fresh project` 还是 `existing project`
2. 执行共享初始化脚本：`../sdlc-workflow/scripts/init-project.sh`
3. 若为 existing project，执行：`../sdlc-workflow/references/existing-project-intake.md`
4. 将 prompt 中给出的最少流程参数写入 `.env`

## 可选 prompt

支持自然语言或键值对，优先提取：

- `tg=@username`
- `review=1`
- `branch=feat/`

若 prompt 未给出：

- `TG_USERNAME` 优先尝试从运行时上下文获取
- `REVIEW_MAX_ROUNDS` 默认写为 `1`

## 执行步骤

1. 读取 `../sdlc-workflow/scripts/init-project.sh`
2. 判断项目类型：
   - 若已有 `apps/`、`packages/`、`src/`、`package.json`、`pnpm-workspace.yaml`、`turbo.json`、`.git/` 等工程结构，则视为 existing project
   - 否则视为 fresh project
3. 运行：

```bash
bash ../sdlc-workflow/scripts/init-project.sh .
```

4. 若 prompt 中带有 `tg` / `review` / `branch`，运行：

```bash
bash ../sdlc-workflow/scripts/update-workflow-config.sh --project-root . --tg <username> --review-rounds <n> --branch-prefix <prefix>
```

5. 若为 existing project，严格按照 `../sdlc-workflow/references/existing-project-intake.md` 生成：
   - `docs/PROJECT_BASELINE.md`
   - `docs/EXISTING_STRUCTURE.md`
   - `docs/TEST_BASELINE.md`

## 输出

- `.claude/CLAUDE.md`
- `.claude/rules/workflow-rules.md`
- `docs/ARCHITECTURE.md`
- `docs/SECURITY.md`
- `docs/CODING_GUIDELINES.md`
- `.env.example`
- `.env`
- existing project 额外 baseline 文档

## 结束条件

输出一段简短总结，至少包含：

1. `fresh` 还是 `existing`
2. 初始化生成了哪些文件
3. 是否已写入 `TG_USERNAME`
4. `REVIEW_MAX_ROUNDS` 当前值
5. 后续建议使用 `/sdlc-doit` 还是 `/sdlc-doit-mini`
