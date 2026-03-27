---
name: sdlc-workflow
description: >-
  Full SDLC automation pipeline with dual-model review gates
  (Claude Code generates, Codex CLI reviews).
  Use when starting a new feature, processing requirements from text/URL/JIRA,
  running automated development workflow.
  Triggers: start workflow, new feature, process requirement, run pipeline,
  SDLC, digital worker, development automation, requirements to PR.
argument-hint: "init [配置] | doit <需求> | mini <小任务>"
homepage: https://github.com/<org>/sdlc-workflow
metadata:
  openclaw:
    emoji: "🏭"
    requires:
      bins: ["codex", "gh", "openclaw"]
    install:
      - id: codex
        kind: npm
        package: "@openai/codex"
        bins: ["codex"]
        label: "Install Codex CLI (OpenAI)"
      - id: gh
        kind: brew
        formula: "gh"
        bins: ["gh"]
        label: "Install GitHub CLI"
      - id: openclaw
        kind: npm
        package: "openclaw"
        bins: ["openclaw"]
        label: "Install OpenClaw CLI"
---

## 命令分工

当前稳定入口是单入口多模式：

- `/sdlc-workflow init`：初始化或接入项目
- `/sdlc-workflow doit`：标准需求完整流程
- `/sdlc-workflow mini`：小任务轻量流程

分入口目录 `sdlc-init`、`sdlc-doit`、`sdlc-doit-mini` 仍保留为实现和实验形态，但对外推荐统一使用 `/sdlc-workflow`，以降低技能注册和热加载不稳定带来的问题。

注意：

- `/sdlc-doit-mini` 是轻量流程，不是跳过流程
- mini 模式仍必须执行：
  - iteration 产物生成
  - mini Gate 1
  - validation capability detection
  - mini Gate 2
  - Chrome DevTools MCP + WebMCP 最终验收

## 项目初始化

检查当前项目是否已初始化 SDLC 工作流结构：

1. 先判断当前项目是 fresh project 还是 existing project：
   - 若已存在 `apps/`、`packages/`、`src/`、`package.json`、`pnpm-workspace.yaml`、`turbo.json`、`.git/` 等业务/工程结构 → existing project
   - 若目录基本为空，仅准备首次接入 workflow → fresh project
2. 检测 `.claude/CLAUDE.md` 和 `docs/ARCHITECTURE.md` 是否存在
3. 若两者都存在 → 项目已初始化，跳过，直接进入 Part 2
4. 若任一不存在 → 执行初始化：
   - 运行 `bash ~/.agents/skills/sdlc-workflow/scripts/init-project.sh .`
   - 生成项目结构（.claude/, docs/, tests/, .env.example）
   - 提醒用户：若 `.env` 不存在，从 `.env.example` 复制并填写 TG_USERNAME
5. 若判定为 existing project，则初始化后必须先执行 `references/existing-project-intake.md`：
   - 生成 `docs/PROJECT_BASELINE.md`
   - 生成 `docs/EXISTING_STRUCTURE.md`
   - 生成 `docs/TEST_BASELINE.md`
   - 在基线完成前，不得直接进入 requirements/design/tasks

## TG_USERNAME 自动检测

Pipeline 启动时按以下优先级确定 TG_USERNAME：

1. **运行时上下文检测**（TG/OpenClaw 触发场景）：
   - 检查环境变量 `OPENCLAW_TRIGGER_USER`（OpenClaw 触发时自动注入）
   - 若存在 → 初始化阶段自动创建 `.env`（若缺失）并写入 `TG_USERNAME`
   - 日志: "📱 检测到 TG 用户: @<username>，已自动配置"

2. **读取 `.env` 文件**：
   - 若 `.env` 存在且 TG_USERNAME 已设置 → 使用该值
   - 若 `.env` 不存在且未处于 TG 触发场景 → 提示用户从 `.env.example` 复制
   - 若 TG_USERNAME 为空 → 提示用户手动配置

3. **兜底**：
   - 若以上均无法获取 → 提示 "请在 .env 中设置 TG_USERNAME" → 暂停

## 配置读取

从项目 `.env` 文件读取所有配置变量。未设置的变量使用默认值：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| TG_USERNAME | (空) | 必需，Telegram 用户名 |
| TEST_FRAMEWORK | jest | 单元测试框架 |
| E2E_FRAMEWORK | playwright | 固定 E2E 测试框架 |
| LINT_TOOL | eslint | Lint 工具 |
| REVIEW_MAX_ROUNDS | 1 | 审查最大轮数 |
| GIT_BRANCH_PREFIX | feat/ | Git 分支前缀 |
| COMMIT_SCOPE | (空) | Commit scope |

## 迭代目录命名规则

每次 Pipeline 运行创建一个迭代目录：

  docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/

命名规则：
- YYYY-MM-DD: 当天日期
- <seq>: 当天内递增的 3 位序号，从 `001` 开始
- <slug>: 需求名称的 kebab-case 形式（从需求内容提取关键词，≤30 字符）
- <type>: 变更类型，从以下枚举中选择：
  feature | fix | refactor | docs | test | chore

示例：
  docs/iterations/2026-03-25/001-user-login-feature/
  docs/iterations/2026-03-25/002-password-reset-fix/
  docs/iterations/2026-03-26/001-cache-layer-refactor/

该目录下包含：requirements.md, design.md, tasks.md

## Pipeline 编排

### 步骤概览

| 步骤 | 名称 | 说明 |
|------|------|------|
| ⓪ | 初始化 + 模式识别 | fresh/existing 分流 → init-project.sh → existing intake → TG_USERNAME → .env → 迭代目录 |
| ① | requirements-ingestion | 识别输入类型 → 提取/读取/解析 → requirements.md |
| ② | requirements-clarifier | 逐条分析置信度，标注确认/假设/提问 |
| ③ | design-generator | 生成 design.md（引用历史 iterations） |
| ④ | task-generator | design.md → tasks.md |
| ⑤ | design-reviewer | **Gate 1**: Codex CLI 审查设计 |
| ⑥ | Claude Code 开发 | 按 tasks.md 逐任务实现代码 |
| ⑦ | test-generator | 生成 tests/unit/ + tests/e2e/ |
| ⑧ | code-reviewer | **Gate 2**: Codex CLI 审查代码 |
| ⑨ | test-pipeline | lint → unit → Playwright 预检 → Chrome DevTools MCP / WebMCP 最终交互测试 |
| ⑩ | docs-updater | 更新文档 + CLAUDE.md iterations 引用 |
| ⑪ | git-committer | branch → commit → push → PR |

### 详细流程

#### ⓪ 初始化
```
MODE=$(detect_project_mode)  # fresh | existing

IF NOT (.claude/CLAUDE.md AND docs/ARCHITECTURE.md):
  RUN init-project.sh

IF MODE == existing:
  RUN existing-project-intake
  REQUIRE docs/PROJECT_BASELINE.md
  REQUIRE docs/EXISTING_STRUCTURE.md
  REQUIRE docs/TEST_BASELINE.md

IF OPENCLAW_TRIGGER_USER:
  ENSURE .env EXISTS (copy from .env.example if missing)
  WRITE .env TG_USERNAME=OPENCLAW_TRIGGER_USER
  LOG "📱 检测到 TG 用户: @<username>，已自动配置"

IF NOT .env:
  COPY .env.example TO .env
  LOG "请编辑 .env 设置 TG_USERNAME"

READ .env

SLUG=$(generate_slug_from_requirements "$INPUT")  # 优先语义化英文 slug，失败则 req-<hash8>
TYPE=$(infer_type "$INPUT")  # feature|fix|refactor|docs|test|chore
DATE=$(date +%Y-%m-%d)
DATE_DIR="docs/iterations/$DATE"
MKDIR -p "$DATE_DIR"
LAST_SEQ=$(find "$DATE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | \
  sed -n 's/^\([0-9][0-9][0-9]\)-.*/\1/p' | sort | tail -n1)
IF [ -n "$LAST_SEQ" ]; THEN
  SEQ=$(printf "%03d" $((10#$LAST_SEQ + 1)))
ELSE
  SEQ="001"
FI
ITER_DIR="$DATE_DIR/$SEQ-$SLUG-$TYPE/"
MKDIR -p "$ITER_DIR"
```

#### ① requirements-ingestion
- 输入类型路由：文本 → 直接解析；file:// → 读取文件；URL → Chrome DevTools MCP
- 输出：docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/requirements.md
- 通知 TG：📥 需求已收录

#### ② requirements-clarifier
- 逐条分析 confidence：
  - 高(≥0.8): 添加 [✅ 已确认]
  - 中(0.5-0.8): 添加 [⚠️ 假设: ...]
  - 低(<0.5): TG 提问 + 假设标注（不阻塞）
- 输出：更新后的 requirements.md

#### ③ design-generator
- 读取：requirements.md + docs/ARCHITECTURE.md + docs/SECURITY.md + docs/iterations/（历史）
- 若为 existing project，额外读取：`docs/PROJECT_BASELINE.md` + `docs/EXISTING_STRUCTURE.md` + `docs/TEST_BASELINE.md`
- 设计必须声明代码落位：默认遵循 Better-T-Stack 风格 `apps/web` / `apps/server` / 条件启用的 `packages/*`
- 若为 existing project，必须明确说明“沿用既有结构”还是“本轮经批准的结构调整”
- 输出：docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/design.md

#### ④ task-generator
- 输入：design.md
- 输出：docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/tasks.md

#### ⑤ design-reviewer (Gate 1)
```
round=1
WHILE round <= REVIEW_MAX_ROUNDS:
  result=$(codex exec --full-auto "审查设计...")
  IF result == PASS:
    通知 TG: 🔍 设计 Review: PASS ✅
    BREAK
  ELSE:
    IF round < REVIEW_MAX_ROUNDS:
      通知 TG: 🔍 设计 Review 第{round}轮: <问题>
      CLAUDE 修订 design.md + tasks.md
    ELSE:
      通知 TG: ⚠️ 设计 Review 超过 {N} 轮，需人工介入
      ABORT
  round+=1
```

#### ⑥ Claude Code 开发
按 tasks.md 逐任务实现代码，并在实现偏离 design.md 时同步修订 design/tasks，避免 Gate 2 审查对象与真实代码脱节。每完成一个任务后，必须同步回写 `tasks.md`：

- 将任务标题从 `### [ ] T-xxx` 改为 `### [x] T-xxx`
- 将该任务下已实际满足的验收标准勾选为 `[x]`
- 未完成或部分完成的任务不得提前勾选

#### ⑦ test-generator
- 输入：tasks.md + git diff
- 输出：
  - tests/unit/web|server|packages/...
  - tests/e2e/<slug>/E2E-<nnn>-<scenario>.e2e.ts
  - tests/reports/<slug>-coverage.md

#### ⑧ code-reviewer (Gate 2)
```
round=1
WHILE round <= REVIEW_MAX_ROUNDS:
  result=$(codex exec --full-auto "审查代码...")
  IF result == PASS:
    通知 TG: 🔍 Code Review: PASS ✅
    BREAK
  ELSE:
    IF round < REVIEW_MAX_ROUNDS:
      通知 TG: 🔍 Code Review 第{round}轮: <问题>
      CLAUDE 修复代码
    ELSE:
      通知 TG: ⚠️ Code Review 超过 {N} 轮，需人工介入
      ABORT
  round+=1
```

Gate 2 还必须检查 `tasks.md` 状态是否与真实实现一致：

- 已实现的任务是否同步勾选
- 已勾选的验收标准是否能被代码、测试和报告支撑
- 是否存在“代码已完成但任务仍未完成”或“任务已勾选但证据不足”的状态漂移

#### ⑨ test-pipeline
```
STAGE 1: npx $LINT_TOOL .        # 快速失败
STAGE 2: npx $TEST_FRAMEWORK     # unit tests
STAGE 3: npx playwright test # Playwright tests
STAGE 4: Chrome DevTools MCP validation
STAGE 5: WebMCP validation

IF any failure:
  IF round < REVIEW_MAX_ROUNDS:
    通知 TG: 🧪 失败用例: <列表>
    CLAUDE 修复
    retry
  ELSE:
    通知 TG: ⚠️ 测试修复超过 {N} 轮
    ABORT

通知 TG: 🧪 测试结果: <通过数>/<总数>
```

#### ⑩ docs-updater
按变更更新：
- README.md — 新增功能说明
- docs/ARCHITECTURE.md — 架构层面变更
- docs/SECURITY.md — 安全相关变更
- docs/CODING_GUIDELINES.md — 新模式/约定
- .claude/CLAUDE.md — **更新 iterations 引用列表**

#### ⑪ git-committer
```bash
git checkout -b ${GIT_BRANCH_PREFIX}<slug>-YYYY-MM-DD
git add -A
git commit -m "<type>(scope): <摘要>"
git push origin ${GIT_BRANCH_PREFIX}<slug>-YYYY-MM-DD
gh pr create --title "<type>(scope): <摘要>" --body "..."
PR_URL=$(gh pr view --json url --jq .url)
```

#### 最终通知
通知 TG: ✅ PR: <url> | 变更: N files | 测试: 全部通过

## TG 通知命令

所有通知统一使用 OpenClaw CLI：
```bash
openclaw message send --channel telegram --target "$TG_USERNAME" --message "$MSG"
```

通知列表：
1. 需求收录：📥 需求已收录: <摘要前50字>
2. 需求澄清：❓ 需确认: <问题列表>（已标注假设，流程继续）
3. 设计 Review：🔍 设计 Review: PASS ✅ 或 🔍 设计 Review 第N轮: <问题摘要>
4. Code Review：🔍 Code Review: PASS ✅ 或 🔍 Code Review 第N轮: <问题列表>
5. 测试完成：🧪 测试结果: <通过数>/<总数> 通过 或 🧪 失败用例: <列表>
6. 循环超限：⚠️ 需人工介入: <Gate名称> 超过 N 轮未通过
7. 迭代完成：✅ PR: <url> | 变更: N files | 测试: 全部通过

## 循环与回退规则

| 循环点 | 触发条件 | 回退到 | 最大轮数 | 超限行为 |
|--------|----------|--------|----------|----------|
| Gate 1 (⑤) | Codex 返回 FAIL | 步骤③ design-generator | REVIEW_MAX_ROUNDS | 📱 TG 中止通知 |
| Gate 2 (⑧) | Codex 返回 FAIL | 步骤⑥ Claude Code 开发 | REVIEW_MAX_ROUNDS | 📱 TG 中止通知 |
| Test (⑨) | 测试失败 | 步骤⑥ Claude Code 开发 | REVIEW_MAX_ROUNDS | 📱 TG 中止通知 |

## 全局规则

1. **单 Agent 模式**：所有步骤由一个 Claude Code Agent 执行
2. **双模型把关**：Claude Code 生成，Codex CLI 审查
3. **循环上限**：每个 Gate/Test ≤ REVIEW_MAX_ROUNDS（默认 1）
4. **Conventional Commits**：`<type>(scope): description`
5. **禁止直推**：所有变更通过 feature branch + PR
6. **通知不中断**：TG 通知失败只 log，不影响 Pipeline
7. **安全优先**：禁止在通知/日志中泄露敏感信息
8. **文件隔离**：所有文件操作限项目根目录内
9. **渐进式加载**：SKILL.md ≤500 行，详细规范按需从 references/ 加载
10. **模板不覆盖**：init-project.sh 不覆盖已存在的文件
11. **统一测试目录**：单元测试只能写入 `tests/unit/web|server|packages`，E2E 只能写入 `tests/e2e/`，报告写入 `tests/reports/`
13. **E2E 证据要求**：关键用户路径的最终报告必须以 Chrome DevTools MCP 和 WebMCP 的交互验证结果为准；Playwright 仅作为预检
14. **需求到测试唯一映射**：requirements、tasks、E2E 场景必须有唯一 ID 映射，禁止重复覆盖同一需求路径
12. **迭代可追溯**：docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/
13. **审查门禁不可降级**：Codex CLI 不可用时必须中止，不能自动跳过 Gate
14. **全栈目录约束**：默认采用 Better-T-Stack 风格 monorepo，业务代码不应随意落到根目录级 `web/`/`api/`/`server/`
