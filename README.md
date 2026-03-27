# 企业级 SDLC Workflow — AI 驱动的 24 小时自动化软件交付流水线

<p align="center">
  <strong>🏭 用 Claude Code 做开发 · 用 Codex CLI 做审查 · 用 Telegram 追进度</strong>
</p>

<p align="center">
  <a href="./DESIGN-PROMO.md#设计哲学">💡 设计理念</a> ·
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
- 🦞 **远程开发**：支持 OpenClaw TG channel 频道，远程下达开发需求指令，开发过程实时追踪
- 🤖 **AI 驱动**：完全由 AI 驱动，无需人工干预
- 🎯 **全流程自动化**：从需求采集到 PR 合并，中间有设计审查、代码审查、浏览器验收，每一步都有产物、有证据、可恢复
- 🔧 **可恢复，不怕中断**：每轮需求生成结构化的 iteration 目录，会话中断后，依赖 Git + iteration 产物可以让下一个 session 续跑
- 🔐 **三道门禁**：设计审查、代码审查、浏览器自动验收审查，严格把控交付质量

## 为什么需要它

你已经在用 Claude Code / Cursor / Codex 写代码了。但你大概率遇到过这些场面：

| 痛点 | 你现在怎么处理 | 用了这套系统之后 |
|------|--------------|----------------|
| 老项目交给 AI，被当新项目重建 | 反复解释"别动现有架构" | 先 intake 再开发，baseline 锁定现有结构 |
| 模型擅自把目录结构改了 | 事后人工修，或者放弃 | 目录约束作为规则注入，改不了 |
| 说"已完成"但实际没测 | 手动逐个验证 | 最终通过必须有浏览器交互证据 |
| 审查全靠自己看 diff | 通常看不过来就跳过了 | Codex CLI 自动审查，Gate 失败就停 |
| 做了什么改动，过两天就忘 | 翻 Git log 猜 | 每轮需求生成独立 iteration 目录 |
| 小改动不想跑全流程 | 直接裸改，没记录 | mini 模式：精简流程，但仍有 Gate 和验收以及变更留底和TG通知 |

**一句话总结**：这是一套用 **工程 contract** 而非 prompt 技巧来约束 AI 行为的 SDLC 系统。

---



## 核心命令

```bash
# 初始化：接入你的项目（tg= 填你的 Telegram 账号数字 ID）
/sdlc-workflow init "tg=123456789 review=1"

# 标准需求：走完整 12 步流程
/sdlc-workflow doit 增加用户登录模块，支持邮箱和手机号注册

# 小任务：走精简流程，但不跳过 Gate
/sdlc-workflow mini 把按钮颜色改成蓝色
```

> **前置条件**：使用 TG 通知前需先配置 OpenClaw CLI（`npm i -g openclaw && openclaw auth login && openclaw channel connect telegram`），获取你的 Telegram 账号数字 ID 或 chat_id。

---

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


**mini 不是"跳过流程"**：浏览器验收不精简，Gate 不跳过。影响 > 3 文件或改 API/数据模型时自动升级到 doit。


---

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

## evn 配置项

在项目根目录的 `.env` 中配置（`/sdlc-workflow init` 会自动生成）：

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `TG_USERNAME` | — | Telegram 账号数字 ID 或 chat_id |
| `REVIEW_MAX_ROUNDS` | `1` | Gate/Test 最大循环轮数 |
| `GIT_BRANCH_PREFIX` | `feat/` | Git 分支前缀 |
| `TEST_FRAMEWORK` | `jest` | 单元测试框架（jest/vitest/mocha） |
| `LINT_TOOL` | `eslint` | Lint 工具（eslint/biome） |
| `TEST_BOOTSTRAP_POLICY` | `report` | 测试基础设施缺口处理策略 |

---

## 与其他方案的对比

| | 裸用 Claude Code | Cursor Rules | SDLC Workflow |
|--|-----------------|--------------|---------------|
| 目录结构约束 | ❌ 靠 prompt 祈祷 | ⚠️ 可配规则，无运行时强制 | ✅ 注入 workflow，运行时强制 |
| 设计审查 | ❌ 无 | ❌ 无 | ✅ Codex CLI Gate 1 |
| 代码审查 | ❌ 无 | ❌ 无 | ✅ Codex CLI Gate 2 |
| 测试验收 | ⚠️ 口述"已测试" | ⚠️ 口述"已测试" | ✅ 浏览器交互证据 |
| 迭代可恢复 | ❌ 依赖聊天记录 | ❌ 依赖聊天记录 | ✅ Git + iteration 目录 |
| 老项目安全接入 | ❌ 经常被重建 | ⚠️ 看运气 | ✅ intake → baseline → 约束 |
| 远程运行 | ⚠️ 部分支持 | ❌ 桌面端 | ✅ OpenClaw / TG 原生支持 |

---

## FAQ

**Q: 没有 Codex CLI 能用吗？**
> 当前设计下不行。Gate 是强制的。可以 fork 后修改 Gate 步骤为人工审查。

**Q: 支持 TypeScript 以外的项目吗？**
> 支持。配置 `TEST_FRAMEWORK` 和 `LINT_TOOL` 即可适配。流程本身不依赖特定语言。

**Q: mini 和 doit 怎么选？**
> 改 CSS、改文案、小 UI 修 → mini。改 API、改数据模型、涉及多模块 → doit。mini 过程中发现影响范围大会自动升级。

**Q: 会话中断了怎么办？**
> 下一个 session 读取 `docs/iterations/` 和 Git 状态即可续跑。所有中间产物都已持久化在文件系统里。

---

## 实践工程案例
https://github.com/evan-taojiangcb/btc-trade/pulls

---

## License

[MIT](./sdlc-workflow/LICENSE)
