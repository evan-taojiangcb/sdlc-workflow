# SDLC Workflow Rules

- 文件操作限项目根目录内
- 日期格式: YYYY-MM-DD
- 迭代目录格式: docs/iterations/YYYY-MM-DD/<slug>-<type>/
  - <slug>: 需求名 kebab-case (≤30 字符)
  - <type>: feature | fix | refactor | docs | test | chore
- Commit: Conventional Commits (feat/fix/docs/refactor/test/chore)
- 通知统一走 OpenClaw CLI
- Review/Test 循环上限由 REVIEW_MAX_ROUNDS 控制（默认 3 轮）
- 超限通知人工 + 中止 Pipeline
- 禁止直推 main/master 分支
- 禁止通知/日志泄露敏感信息（密钥/Token/密码）
- Codex CLI 统一使用 --approval-mode full-auto
- Codex CLI 不可用时必须中止，不能自动跳过 Gate
- 测试文件统一存放 tests/ 目录（unit/ + e2e/ + reports/）
- 新需求处理前必须参考 docs/iterations/ 历史上下文
