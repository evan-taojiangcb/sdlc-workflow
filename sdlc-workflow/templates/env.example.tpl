# ╔══════════════════════════════════════════════════════════════╗
# ║            SDLC Workflow 项目配置文件                         ║
# ║  复制此文件为 .env 并填写配置:  cp .env.example .env          ║
# ╚══════════════════════════════════════════════════════════════╝

# ──────────────────────────────────────────────────────────────
# 通知配置
# ──────────────────────────────────────────────────────────────

# [必需] Telegram 通知目标
# 说明: 工作流关键节点（需求收录/Review/测试/完成）的通知目标
# 格式: Telegram 账号数字 ID 或 chat_id
# 示例: TG_USERNAME=123456789
#
# ⚠️ 前置条件: 使用前需先配置 OpenClaw CLI 并获取你的 Telegram 账号 ID
#   1. 安装: npm install -g openclaw
#   2. 登录: openclaw auth login
#   3. 绑定 TG: openclaw channel connect telegram
#   4. 获取 ID: openclaw channel info telegram → 得到数字 ID
#
# 注意: 若通过 TG/OpenClaw 触发工作流，此值会自动从触发上下文获取并写入
TG_USERNAME=

# ──────────────────────────────────────────────────────────────
# 测试配置
# ──────────────────────────────────────────────────────────────

# [可选] 单元测试框架
# 枚举值: jest | vitest | mocha
# 默认值: jest
# 说明: 用于执行 tests/unit/ 下的测试文件
# - jest:   npx jest (需安装 jest)
# - vitest: npx vitest run (需安装 vitest, 适合 Vite 项目)
# - mocha:  npx mocha (需安装 mocha, 传统 Node.js 项目)
TEST_FRAMEWORK=jest

# [固定] E2E 测试框架
# 固定值: playwright
# 说明: Playwright 只用于预检；最终交互测试与最终测试报告以 Playwright MCP + WebMCP 为准
# - playwright: 执行 tests/e2e/ 下的预检脚本
# - Playwright MCP: 页面/控制台/网络验证
# - WebMCP: 最终关键交互链路复核
E2E_FRAMEWORK=playwright

# [可选] 是否并行执行 Unit 与 E2E
# 枚举值: true | false
# 默认值: false
# 说明: 仅当 E2E 不依赖 lint/build 产物时开启；否则保持串行，避免假失败
PARALLEL_TESTS=false

# [可选] Lint 工具
# 枚举值: eslint | biome
# 默认值: eslint
# 说明: 代码静态检查，在测试执行前运行（快速失败）
# - eslint: npx eslint . (传统 JS/TS lint，生态丰富)
# - biome:  npx biome check . (Rust 实现，速度快，lint+format 二合一)
LINT_TOOL=eslint

# [可选] 测试基础设施补齐策略
# 枚举值: report | auto | never
# 默认值: report
# 说明:
# - report: 检测到缺少 lint/unit/playwright/browser 验收能力时，不交互追问，直接在报告/TG 中列出缺口与建议命令
# - auto:   在允许的场景下自动补齐缺少的测试基础设施（更适合 fresh project）
# - never:  检测到缺口后直接中止，不尝试补齐
# 远程/OpenClaw 场景建议 existing project 使用 report，避免交互式 ask 卡住流程
TEST_BOOTSTRAP_POLICY=report

# ──────────────────────────────────────────────────────────────
# 审查配置
# ──────────────────────────────────────────────────────────────

# [可选] Review/Test 最大循环轮数
# 类型: 正整数
# 默认值: 1
# 范围: 1-10
# 说明: 设计审查(Gate1)、代码审查(Gate2)、测试修复 每个环节的最大重试次数
#       超过此轮数仍未通过 → 发送 TG 通知 → 中止 Pipeline → 等待人工介入
REVIEW_MAX_ROUNDS=1

# ──────────────────────────────────────────────────────────────
# Git 配置
# ──────────────────────────────────────────────────────────────

# [可选] Git 分支前缀
# 类型: 字符串，以 / 结尾
# 默认值: feat/
# 说明: 创建分支时的前缀。最终分支名: ${GIT_BRANCH_PREFIX}<slug>-YYYY-MM-DD
# 示例:
# - feat/    → feat/user-login-2026-03-25
# - fix/     → fix/password-reset-2026-03-25
# - feature/ → feature/user-login-2026-03-25
GIT_BRANCH_PREFIX=feat/

# [可选] Conventional Commits scope
# 类型: 字符串
# 默认值: （留空，自动从变更文件路径推断）
# 说明: commit message 中的 scope 部分 → feat(scope): description
# 示例:
# - auth     → feat(auth): add user login
# - api      → fix(api): handle timeout error
# - 留空     → 自动检测: 根据修改最多的目录推断
COMMIT_SCOPE=

# [可选] PR body 模板路径
# 类型: 文件路径（相对项目根目录）
# 默认值: （使用内置模板）
# 说明: 自定义 gh pr create --body 的模板文件
#       模板中可使用占位符: {{requirements}}, {{design}}, {{test_summary}}, {{file_list}}
# 示例: PR_TEMPLATE=.github/pull_request_template.md
PR_TEMPLATE=
