# Memory - SDLC Workflow Project

## 项目概述
- **名称**: sdlc-workflow
- **路径**: `/Volumes/HS-SSD-1TB/works/work-piple-1`
- **用途**: AI 驱动的 SDLC 自动化流水线技能
- **架构**: 单 Agent + 双模型把关（Claude Code 生成 / Codex CLI 审查）
- **版本**: v7

## 目录结构
```
sdlc-workflow/               # 技能仓库
├── SKILL.md                 # 入口（Pipeline 编排）
├── references/              # 12 个步骤详细规范
├── templates/               # 6 个项目初始化模板
├── scripts/                 # init-project.sh
├── README.md
└── LICENSE

~/.claude/skills/           # 技能安装位置（符号链接）
└── sdlc-workflow → /Volumes/HS-SSD-1TB/works/work-piple-1/sdlc-workflow
```

## 技能安装方式
Claude Code 技能需要链接到 `~/.claude/skills/`，不是 `~/.agents/skills/`
```bash
ln -sf /Volumes/HS-SSD-1TB/works/work-piple-1/sdlc-workflow ~/.claude/skills/sdlc-workflow
```

## 技能触发方式
```bash
claude --dangerously-skip-permissions "/sdlc-workflow <需求>"
```
注意：需要 `--dangerously-skip-permissions` 跳过权限检查

## 测试项目
- **路径**: `/Volumes/HS-SSD-1TB/work-test-piple-1`
- **测试用例**:
  1. 第一次迭代: 创建一个计算器功能，支持加减乘除运算
  2. 第二次迭代: 改造为 H5 端版本，采用黑色主题

## 测试验证结果

### 第一次迭代 (calculator-feature)
- 迭代目录: `docs/iterations/2026-03-26/calculator-feature/`
- 生成代码: `src/calculator.ts`, `src/operations.ts`, `src/index.ts`
- 测试文件: `tests/unit/calculator.test.ts` (15 个测试通过)
- 状态: ✅ 成功

### 第二次迭代 (h5-dark-theme-feature)
- 迭代目录: `docs/iterations/2026-03-26/h5-dark-theme-feature/`
- 生成代码: `web/index.html`, `web/styles.css`, `web/app.js`
- 测试文件: `tests/e2e/h5-calculator.e2e.ts`
- 状态: ✅ 成功

## 设计要点验证

### 1. 迭代目录命名规则 ✅
- 格式: `YYYY-MM-DD/<slug>-<type>/`
- 支持同日多需求并行（`2026-03-26/` 下有 2 个迭代）
- `<type>` 枚举: feature | fix | refactor | docs | test | chore

### 2. 统一测试目录 ✅
- 取消 `specs/`，统一在 `tests/`
- `tests/unit/` - 单元测试
- `tests/e2e/` - E2E 测试
- `tests/reports/` - 测试报告

### 3. CLAUDE.md 迭代历史引用 ✅
- `.claude/CLAUDE.md` 包含 `## 迭代历史` 章节
- 引用 `docs/iterations/` 目录

### 4. 第二次迭代产物位置
- **问题**: H5 前端代码在 `web/` 而不是 `src/`
- **原因**: 第二次迭代需求是"改造为 H5 端"，Claude Code 按需求生成了 `web/`
- **说明**: 第一次迭代生成 `src/` (核心逻辑)，第二次迭代生成 `web/` (H5 前端)

## 遗留问题
1. `web/` 目录 vs `src/` 目录结构问题 - 用户希望所有代码在 src 下，但第二次迭代按需求生成了 web/

## 相关文件路径
- 技能源码: `/Volumes/HS-SSD-1TB/works/work-piple-1/sdlc-workflow/`
- 测试项目: `/Volumes/HS-SSD-1TB/work-test-piple-1/`
- 记忆文件: `/Volumes/HS-SSD-1TB/works/work-piple-1/MEMORY.md`
