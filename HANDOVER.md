# SDLC Workflow 项目交接文档

## 项目信息
- **项目名称**: sdlc-workflow
- **项目路径**: `/Volumes/HS-SSD-1TB/works/work-piple-1`
- **Git 状态**: 非 Git 仓库（无 .git）

## 项目背景
基于 Google Cloud 5 种 Agent 设计模式 + Claude Code Skills 架构，构建可编排的自动化 SDLC 工作流。
- **单 Agent 模式** + **双模型把关**（Claude Code 生成 / Codex CLI 审查）
- **版本**: v7

## 目录结构
```
sdlc-workflow/
├── SKILL.md                     # 入口（Pipeline 编排 + frontmatter）
├── references/                  # 12 个步骤详细规范
│   ├── pipeline-overview.md
│   ├── requirements-ingestion.md
│   ├── requirements-clarifier.md
│   ├── design-generator.md
│   ├── task-generator.md
│   ├── design-reviewer.md
│   ├── test-generator.md
│   ├── code-reviewer.md
│   ├── test-pipeline.md
│   ├── docs-updater.md
│   ├── git-committer.md
│   └── tg-notifier.md
├── templates/                   # 6 个项目初始化模板
│   ├── CLAUDE.md.tpl
│   ├── workflow-rules.md.tpl
│   ├── ARCHITECTURE.md.tpl
│   ├── SECURITY.md.tpl
│   ├── CODING_GUIDELINES.md.tpl
│   └── env.example.tpl
├── scripts/
│   └── init-project.sh
├── README.md
├── LICENSE
└── MEMORY.md                   # 记忆文件
```

## 核心设计决策（v7）

### 1. 迭代目录命名
- **格式**: `docs/iterations/YYYY-MM-DD/<slug>-<type>/`
- **支持同日多需求**: 同一日期下可创建多个迭代目录
- **type 枚举**: feature | fix | refactor | docs | test | chore

### 2. 统一测试目录
- **取消 specs/**，统一在 `tests/`
- `tests/unit/` - 单元测试
- `tests/e2e/` - E2E 测试
- `tests/reports/` - 测试报告

### 3. CLAUDE.md 迭代历史引用
- `.claude/CLAUDE.md` 包含 `## 迭代历史` 章节
- 引用 `docs/iterations/` 目录

### 4. TG_USERNAME 自动检测
- Pipeline 启动时从 `OPENCLAW_TRIGGER_USER` 环境变量自动获取
- 写入 `.env` 的 TG_USERNAME 字段

## 技能安装方式
Claude Code 技能需要链接到 `~/.claude/skills/`：
```bash
ln -sf /Volumes/HS-SSD-1TB/works/work-piple-1/sdlc-workflow ~/.claude/skills/sdlc-workflow
```

## 技能触发方式
```bash
cd <项目目录>
claude --dangerously-skip-permissions "/sdlc-workflow <需求>"
```

## 测试验证

### 测试项目
- **路径**: `/Volumes/HS-SSD-1TB/work-test-piple-1`
- **Git 仓库**: 已初始化

### 第一次迭代
- **需求**: 创建一个计算器功能，支持加减乘除运算
- **迭代目录**: `docs/iterations/2026-03-26/calculator-feature/`
- **生成代码**: `src/calculator.ts`, `src/operations.ts`, `src/index.ts`
- **测试文件**: `tests/unit/calculator.test.ts` (15 个测试通过)
- **状态**: ✅ 成功

### 第二次迭代
- **需求**: 改造为 H5 端版本，采用黑色主题
- **迭代目录**: `docs/iterations/2026-03-26/h5-dark-theme-feature/`
- **生成代码**: `web/index.html`, `web/styles.css`, `web/app.js`
- **测试文件**: `tests/e2e/h5-calculator.e2e.ts`
- **状态**: ✅ 成功

## 遗留问题

### web 目录 vs src 目录
- **现象**: 第二次迭代生成了 `web/` 目录存放 H5 前端代码
- **分析**: 第一次迭代生成 `src/` (核心逻辑库)，第二次迭代按需求生成 `web/` (H5 前端)
- **用户关注点**: 用户希望所有代码在 `src/` 下，但当前结构是分开的

## Review 重点

请 Code Review 以下内容：

1. **SKILL.md**:
   - frontmatter 是否符合规范
   - Pipeline 编排逻辑是否完整
   - 是否 ≤500 行

2. **references/** (12 个文件):
   - 每个文件的结构是否完整（输入/输出/详细行为/命令模板/错误处理/TG 通知）
   - 是否与 SKILL.md 中的流程一致

3. **templates/** (6 个文件):
   - CLAUDE.md.tpl 是否包含迭代历史章节
   - env.example.tpl 是否包含完整注释和枚举值

4. **init-project.sh**:
   - 是否正确创建目录结构
   - 是否正确复制模板（不覆盖已存在文件）

5. **架构一致性**:
   - 统一测试目录（无 specs/）
   - 迭代目录命名格式
   - 双 Gate 审查机制

## 相关文件路径
- 技能源码: `/Volumes/HS-SSD-1TB/works/work-piple-1/sdlc-workflow/`
- 测试项目: `/Volumes/HS-SSD-1TB/work-test-piple-1/`
- 记忆文件: `/Volumes/HS-SSD-1TB/works/work-piple-1/MEMORY.md`
- 交接文档: `/Volumes/HS-SSD-1TB/works/work-piple-1/HANDOVER.md`

---

*交接文档由 Claude Code 生成*
