# SDLC Workflow — AI 驱动的 24 小时自动化软件交付流水线

<p align="center">
  <strong>🏭 用 Claude Code 做开发 · 用 Codex CLI 做审查 · 用 Telegram 追进度</strong>
</p>

<p align="center">
  <a href="./DESIGN-PROMO.md">📖 设计理念</a> ·
  <a href="./examples/30-second-demo.md">⚡ 30 秒上手</a> ·
  <a href="./sdlc-workflow/SKILL.md">🔧 核心规范</a>
</p>

---

## 这是什么？

一套用在 [Claude Code](https://claude.ai/code) 中的 **Skill 插件**，让 AI 按照完整的 SDLC 流程自动完成：

```
需求采集 → 需求澄清 → 设计生成 → 任务分解 → Gate 1 审查
→ 代码实现 → 测试生成 → Gate 2 审查 → 测试执行
→ 文档更新 → Git 提交 + PR → TG 通知
```

**核心特点**：

- 🔒 **双模型把关**：Claude Code 生成代码，Codex CLI 独立审查（不降级、不跳过）
- 📱 **13 个 TG 通知点**：每个关键环节都发 Telegram，人不在终端也能追踪
- 🛡️ **Existing Project 安全**：自动生成 baseline，防止 AI 乱改你的项目结构
- 🧪 **证据链验收**：Chrome DevTools MCP + WebMCP 做最终验收，不靠"看一眼"

## 安装

### 一键安装（推荐）

在 Claude Code 终端中执行：

```bash
# 1. 注册 marketplace
/plugin marketplace add evan-taojiangcb/sdlc-workflow

# 2. 安装全套 skill
/plugin install sdlc-full@sdlc-workflow
```

安装完成后即可使用 `/sdlc-workflow`、`/sdlc-init`、`/sdlc-doit`、`/sdlc-doit-mini` 四个命令。

### 手动安装（备选）

<details>
<summary>点击展开手动安装步骤</summary>

**全局安装（所有项目可用）**

```bash
git clone https://github.com/evan-taojiangcb/sdlc-workflow.git ~/.claude/sdlc-workflow-repo
mkdir -p ~/.claude/skills
ln -sf ~/.claude/sdlc-workflow-repo/sdlc-workflow ~/.claude/skills/sdlc-workflow
ln -sf ~/.claude/sdlc-workflow-repo/sdlc-init ~/.claude/skills/sdlc-init
ln -sf ~/.claude/sdlc-workflow-repo/sdlc-doit ~/.claude/skills/sdlc-doit
ln -sf ~/.claude/sdlc-workflow-repo/sdlc-doit-mini ~/.claude/skills/sdlc-doit-mini
```

**项目级安装（仅当前项目可用）**

```bash
cd your-project
git clone https://github.com/evan-taojiangcb/sdlc-workflow.git .claude/sdlc-workflow-repo
mkdir -p .claude/skills
ln -sf .claude/sdlc-workflow-repo/sdlc-workflow .claude/skills/sdlc-workflow
ln -sf .claude/sdlc-workflow-repo/sdlc-init .claude/skills/sdlc-init
ln -sf .claude/sdlc-workflow-repo/sdlc-doit .claude/skills/sdlc-doit
ln -sf .claude/sdlc-workflow-repo/sdlc-doit-mini .claude/skills/sdlc-doit-mini
```

</details>

### 依赖项

| 工具 | 用途 | 安装 |
|------|------|------|
| [Claude Code](https://claude.ai/code) | AI 开发代理 | 官网安装 |
| [Codex CLI](https://github.com/openai/codex) | Gate 1/2 独立审查 | `npm i -g @openai/codex` |
| [GitHub CLI](https://cli.github.com/) | PR 创建 | `brew install gh` |
| [OpenClaw CLI](https://github.com/openclaw) | TG 通知发送 | `npm i -g openclaw` |

### TG 通知配置（可选但推荐）

```bash
openclaw auth login                  # 登录
openclaw channel connect telegram    # 绑定 Telegram
openclaw channel info telegram       # 获取你的账号数字 ID
```

## 快速开始

```bash
# 1. 初始化你的项目（tg= 填你的 Telegram 账号数字 ID）
/sdlc-workflow init "tg=123456789 review=1"

# 2. 提一个需求，跑完整流程
/sdlc-workflow doit 增加用户登录模块，支持邮箱和手机号注册

# 3. 或者跑一个小任务
/sdlc-workflow mini 把按钮颜色改成蓝色
```

## 三种模式

| 命令 | 适用场景 | 步骤数 |
|------|---------|--------|
| `/sdlc-workflow init` | 项目接入，生成配置和 baseline | 一次性 |
| `/sdlc-workflow doit` | 正常 feature/fix，完整 SDLC 流程 | 12 步 |
| `/sdlc-workflow mini` | 微小 UI 调整/文案修改 | 10 步（精简） |

## 目录结构

```
sdlc-workflow/              # 核心 Skill（共享流程定义）
├── SKILL.md                # 主流程规范（364 行）
├── references/             # 15 个详细步骤规范
│   ├── pipeline-overview.md
│   ├── requirements-ingestion.md
│   ├── requirements-clarifier.md
│   ├── design-generator.md
│   ├── design-reviewer.md     # Gate 1
│   ├── task-generator.md
│   ├── code-reviewer.md       # Gate 2
│   ├── test-generator.md
│   ├── test-pipeline.md
│   ├── docs-updater.md
│   ├── git-committer.md
│   ├── tg-notifier.md         # TG 通知规范
│   ├── mini-pipeline.md       # mini 模式流程
│   ├── micro-change-mode.md
│   └── existing-project-intake.md
├── scripts/                # 初始化脚本
│   ├── init-project.sh
│   └── update-workflow-config.sh
└── templates/              # 项目模板文件
    ├── CLAUDE.md.tpl
    ├── workflow-rules.md.tpl
    ├── env.example.tpl
    ├── ARCHITECTURE.md.tpl
    ├── SECURITY.md.tpl
    └── CODING_GUIDELINES.md.tpl

sdlc-init/                  # /sdlc-init 入口 Skill
sdlc-doit/                  # /sdlc-doit 入口 Skill
sdlc-doit-mini/             # /sdlc-doit-mini 入口 Skill
```

## 配置项

在项目根目录的 `.env` 中配置（`/sdlc-workflow init` 会自动生成）：

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `TG_USERNAME` | — | Telegram 账号数字 ID 或 chat_id |
| `REVIEW_MAX_ROUNDS` | `1` | Gate/Test 最大循环轮数 |
| `GIT_BRANCH_PREFIX` | `feat/` | Git 分支前缀 |
| `TEST_FRAMEWORK` | `jest` | 单元测试框架（jest/vitest/mocha） |
| `LINT_TOOL` | `eslint` | Lint 工具（eslint/biome） |
| `TEST_BOOTSTRAP_POLICY` | `report` | 测试基础设施缺口处理策略 |

## 设计理念

详见 [DESIGN-PROMO.md](./DESIGN-PROMO.md)

**核心原则**：
1. **结构约束先于模型智能** — 把规则注入 workflow，不靠 prompt 口头约束
2. **双模型把关不可降级** — Codex 挂了就中止，不偷偷跳过
3. **证据链验收** — Chrome DevTools MCP + WebMCP 做最终验收
4. **通知不中断** — TG 发送失败只 log，不影响 Pipeline

## License

[MIT](./sdlc-workflow/LICENSE)
