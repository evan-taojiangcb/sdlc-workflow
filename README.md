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

六条线:
init（初始化）：采集项目信息或初始化项目 → 生成baseline → 锁定结构
proposal（需求拆解）：需求 → 澄清 → 设计 → 任务 → Gate1 → 暂停等人工审核
apply（需求开发）：读取 proposal 产物 → 开发 → 测试 → Gate2 → 验收 → 文档 → PR
doit（全自动）：proposal + apply 不停顿
mini（精简流程）：需求 → 精简设计 → MiniGate1 → 实现 → MiniGate2 → 验收 → PR
worktree（并行开发）：基于 git worktree 隔离多个并行 pipeline，多需求/多 Agent 同时跑互不干扰
```

**核心特点**：
- 🤖 **AI 驱动**：完全由 AI 驱动，无需人工干预
- 🦞 **远程驱动**：支持 OpenClaw TG channel 频道，远程下达开发需求指令，开发过程实时追踪任务进度
- 🎯 **全流程自动化**：从需求采集到 PR 合并，中间有需求设计审查、代码审查、浏览器验收，每一步都有产物、有证据、可恢复
- 🔧 **可恢复，不怕中断**：每轮需求生成结构化的 iteration 目录，会话中断后，依赖 Git + iteration 产物可以让下一个 session 续跑
- 🔐 **三道门禁**：需求设计审查、代码审查、浏览器自动验收审查，严格把控交付质量
- 🔒 **双模型把关**：Claude Code 生成代码，Codex CLI 独立审查（不降级、不跳过）
- 📋 **Proposal / Apply 分离**：需求拆解后暂停等人工审核，审核通过再执行开发，避免 AI 全权决定设计
- 📱 **15 个 TG 通知点**：每个关键环节都发 Telegram，人不在电脑前也能追踪
- 🛡️ **Existing Project 安全**：自动采集项目信息生成 baseline，防止 AI 乱改你的项目结构
- 🧪 **证据链验收**：Playwright MCP + CDP 做最终验收以及录屏截图和验收报告，不靠"看一眼和模型说:我测完了验收通过"
- 🌲 **Worktree 并行开发**：基于 git worktree 隔离多条 pipeline，多需求 / 多 Agent 同时跑、自动分配端口、自动复制 `.env*`，互不干扰

## 为什么需要它
你已经在用 Claude Code / Cursor / Codex 写代码了。但你大概率遇到过这些场面：

| 痛点 | 你现在怎么处理 | 用了这套系统之后 |
|------|--------------|----------------|
| 老项目交给 AI，被当新项目重建 | 反复解释"别动现有架构" | 先 intake 再开发，baseline 锁定现有结构 |
| 模型擅自把目录结构改了 | 事后人工修，或者放弃 | 目录约束作为规则注入，改不了 |
| AI 设计方案没经过人审就直接写代码 | 写完才发现方向不对 | proposal 暂停等人工审核，apply 才开始开发 |
| 说"已完成"但实际没测 | 手动逐个验证 | 最终通过必须有浏览器交互证据 |
| 审查全靠自己看 diff | 通常看不过来就跳过了 | Codex CLI 自动审查，Gate 失败就停 |
| 做了什么改动，过两天就忘 | 翻 Git log 猜 | 每轮需求生成独立 iteration 目录 |
| 小改动不想跑全流程 | 直接裸改，没记录 | mini 模式：精简流程，但仍有 Gate 和验收以及变更留底和TG通知 |
| 多需求并行卡在串行 pipeline | 一个一个排队，hotfix 也得等 | worktree 模式：每个需求独立工作树 + 独立分支 + 端口隔离 |

**一句话总结**：这是一套用 **工程 contract** 而非 prompt 技巧来约束 AI 行为的 SDLC 系统。

---

## 与其他方案的对比

| | 裸用 Claude Code | Cursor Rules | SDLC Workflow |
|--|-----------------|--------------|---------------|
| 目录结构约束 | ❌ 靠 prompt 祈祷 | ⚠️ 可配规则，无运行时强制 | ✅ 注入 workflow，运行时强制 |
| 设计审查 | ❌ 无 | ❌ 无 | ✅ Codex CLI Gate 1 |
| 人工审核门 | ❌ 无 | ❌ 无 | ✅ proposal 暂停 → 人工 → apply |
| 代码审查 | ❌ 无 | ❌ 无 | ✅ Codex CLI Gate 2 |
| 测试验收 | ⚠️ 口述"已测试" | ⚠️ 口述"已测试" | ✅ 浏览器交互证据 |
| 迭代可恢复 | ❌ 依赖聊天记录 | ❌ 依赖聊天记录 | ✅ Git + iteration 目录 |
| 老项目安全接入 | ❌ 经常被重建 | ⚠️ 看运气 | ✅ intake → baseline → 约束 |
| 并行开发隔离 | ❌ 单仓串行 | ❌ 单仓串行 | ✅ git worktree + 端口隔离 + 注册表 |
| 远程运行 | ⚠️ 部分支持 | ❌ 桌面端 | ✅ OpenClaw / TG 原生支持 |

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

安装完成后即可使用 `/sdlc-workflow`命令（支持 init / proposal / apply / doit / mini 五种模式）。

### 手动安装（备选）

<details>
<summary>点击展开手动安装步骤</summary>

**全局安装（所有项目可用）**

```bash
git clone https://github.com/evan-taojiangcb/sdlc-workflow.git ~/.claude/sdlc-workflow-repo
mkdir -p ~/.claude/skills
ln -sf ~/.claude/sdlc-workflow-repo/sdlc-workflow ~/.claude/skills/sdlc-workflow
```

**项目级安装（仅当前项目可用）**

```bash
cd your-project
git clone https://github.com/evan-taojiangcb/sdlc-workflow.git .claude/sdlc-workflow-repo
mkdir -p .claude/skills
ln -sf .claude/sdlc-workflow-repo/sdlc-workflow .claude/skills/sdlc-workflow
```

</details>

### 依赖项

| 工具 | 用途 | 安装 |
|------|------|------|
| [Claude Code](https://claude.ai/code) | AI 开发代理 | 官网安装 |
| [Codex CLI](https://github.com/openai/codex) | Gate 1/2 独立审查 | `npm i -g @openai/codex` |
| [GitHub CLI](https://cli.github.com/) | PR 创建 | `brew install gh` |
| [OpenClaw CLI](https://github.com/openclaw) | TG 通知发送 | `npm i -g openclaw` |
| [chrome devtools mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | 浏览器验收 | claude-code 挂载 mcp |
|[github mcp](https://github.com/github/github-mcp-server) | 自动提交 PR | claude-code 挂载 mcp |



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

# 2. 需求拆解（推荐流程）
/sdlc-workflow proposal 增加用户登录模块，支持邮箱和手机号注册

# 3. 审阅 proposal 产物 → 确认后执行开发
/sdlc-workflow apply

# 4. 或直接全自动（跳过人工审核）
/sdlc-workflow doit 增加用户登录模块

# 5. 或者跑一个小任务
/sdlc-workflow mini 把按钮颜色改成蓝色

# 6. 并行开发：在隔离的 worktree 里同时跑多个需求
/sdlc-workflow worktree create user-login feature
cd ../wt-001-user-login-feature && /sdlc-workflow doit "用户登录功能"
```

> **前置条件**：使用 TG 通知前需先配置 OpenClaw CLI（`npm i -g openclaw && openclaw auth login && openclaw channel connect telegram`），获取你的 Telegram 账号数字 ID 或 chat_id。

---
## 六种模式

| 命令 | 适用场景 | 说明 |
|------|---------|------|
| `/sdlc-workflow init` | 项目接入，生成配置和 baseline | 一次性 |
| `/sdlc-workflow proposal` | 需求拆解 → 等待人工审核 | 步骤 ①-⑤，产出 requirements/design/tasks |
| `/sdlc-workflow apply` | 审核通过后执行开发 → PR | 步骤 ⑥-⑪，从 proposal 产物继续 |
| `/sdlc-workflow doit` | 正常 feature/fix，完整 SDLC 流程（不停顿） | 12 步全自动 |
| `/sdlc-workflow mini` | 微小 UI 调整/文案修改 | 10 步（精简） |
| `/sdlc-workflow worktree` | 多需求并行 / 多 Agent 协作 / 紧急修复打断 | 子命令：create / list / status / remove / gc |

**推荐流程**：`proposal` → 人工审核 → `apply`，确保 AI 设计方案经过人工确认。

**mini 不是"跳过流程"**：浏览器验收不精简，Gate 不跳过。影响 > 3 文件或改 API/数据模型时自动升级到 doit。

**worktree 不是"另开一个流程"**：worktree 只负责隔离工作区与分支，pipeline 仍然走 init/proposal/apply/doit/mini，只是各自跑在独立目录里。

---

## 并行开发（Worktree 模式）

基于 `git worktree` 让一个仓库同时存在多个工作区，每个工作区跑独立 pipeline。

```bash
# 创建并行工作区（自动分配 seq、分支、端口、复制 .env*）
/sdlc-workflow worktree create user-login feature
/sdlc-workflow worktree create payment-bug fix

# 进入工作区跑正常 pipeline
cd ../wt-001-user-login-feature
/sdlc-workflow proposal "用户登录功能"

# 全局总览（聚合所有 worktree 的 status.json）
/sdlc-workflow worktree status

# 列出注册表中的 worktree
/sdlc-workflow worktree list

# PR 合并后清理
/sdlc-workflow worktree remove 001
/sdlc-workflow worktree gc           # 自动清理已合并的工作区
```

| 资源 | 隔离方式 |
|------|---------|
| 工作目录 | `../wt-<seq>-<slug>-<type>/`，主仓的兄弟目录 |
| 分支 | `{GIT_BRANCH_PREFIX}{slug}-{date}-wt{seq}`，git 强制独占 |
| dev server 端口 | `PORT=3000+seq, API_PORT=4000+seq` 自动写入 `.env` |
| `.env*` | 自动从主仓复制（`.env`、`.env.local` 等不受 git 追踪的文件） |
| 注册表 | `.worktrees/worktree-registry.json`（提交到 main，作为多 Agent 协调总线） |
| `node_modules` | 每个 worktree 独立安装（共享 `.git/` 对象库） |

详细规范见 [sdlc-workflow/references/parallel-dev.md](sdlc-workflow/references/parallel-dev.md)，脚本见 [sdlc-workflow/scripts/sdlc-worktree.sh](sdlc-workflow/scripts/sdlc-worktree.sh)。


---

## 目录结构

```
sdlc-workflow/              # 核心 Skill（共享流程定义）
├── SKILL.md                # 主流程规范
├── references/             # 18 个详细步骤规范
│   ├── pipeline-overview.md
│   ├── proposal.md           # 需求拆解命令
│   ├── apply.md              # 需求开发命令
│   ├── parallel-dev.md       # worktree 并行开发规范
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
├── scripts/                # 初始化和并行开发脚本
│   ├── init-project.sh
│   ├── sdlc-worktree.sh       # worktree create/list/status/remove/gc
│   └── update-workflow-config.sh
└── templates/              # 项目模板文件
    ├── CLAUDE.md.tpl
    ├── workflow-rules.md.tpl
    ├── env.example.tpl
    ├── ARCHITECTURE.md.tpl
    ├── SECURITY.md.tpl
    └── CODING_GUIDELINES.md.tpl
```

### 目标项目结构（init 后生成）

```
your-project/
├── .claude/                    # Claude 上下文（统一放置）
│   ├── CLAUDE.md
│   ├── ARCHITECTURE.md
│   ├── SECURITY.md
│   ├── CODING_GUIDELINES.md
│   ├── PROJECT_BASELINE.md     # existing project
│   ├── EXISTING_STRUCTURE.md
│   ├── TEST_BASELINE.md
│   └── rules/
│       └── workflow-rules.md
├── docs/                       # 迭代产物
│   └── iterations/
│       └── YYYY-MM-DD/
│           └── <seq>-<slug>-<type>/
│               ├── requirements.md
│               ├── design.md
│               ├── tasks.md
│               └── status.json
├── tests/
│   ├── unit/
│   ├── e2e/
│   └── reports/
├── .worktrees/                 # worktree 注册表（启用并行开发后生成）
│   └── worktree-registry.json
├── .env
└── .env.example
```

启用 worktree 后，主仓的同级目录会出现 `wt-<seq>-<slug>-<type>/` 兄弟目录，每个工作区结构与主仓一致，但分支、端口、`.env`、`docs/iterations/` 互相独立。

## env 配置项

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
## FAQ

**Q: 没有 Codex CLI 能用吗？**
> 当前设计下不行。Gate 是强制的。可以 fork 后修改 Gate 步骤为人工审查。

**Q: 支持 TypeScript 以外的项目吗？**
> 支持。配置 `TEST_FRAMEWORK` 和 `LINT_TOOL` 即可适配。流程本身不依赖特定语言。

**Q: proposal 和 doit 怎么选？**
> 需要审核设计方案 → proposal + apply。完全信任 AI → doit。改 CSS、改文案 → mini。

**Q: mini 和 doit 怎么选？**
> 改 CSS、改文案、小 UI 修 → mini。改 API、改数据模型、涉及多模块 → doit。mini 过程中发现影响范围大会自动升级。

**Q: 会话中断了怎么办？**
> 下一个 session 读取 `docs/iterations/` 和 Git 状态即可续跑。所有中间产物都已持久化在文件系统里。

**Q: 多个需求要并行开发怎么办？**
> 用 `worktree create` 给每个需求开独立工作区，分支、端口、`.env` 都自动隔离。多个 Claude Code 会话可以同时跑各自的 pipeline 互不干扰，PR 合并后用 `worktree remove` 或 `worktree gc` 清理。

**Q: worktree 和直接 `git worktree add` 有什么区别？**
> `sdlc-workflow worktree` 在 git 原生能力上多做了：自动 seq/slug/分支命名、自动复制 `.env*`（不受 git 追踪）、自动写入隔离端口（`PORT=3000+seq`）、维护注册表用于多 Agent 协调、与 iteration 目录命名对齐。

---

## 实践工程案例
- https://github.com/evan-taojiangcb/btc-trade/pulls
- [梦幻电影院-ERC20](https://movie.coinbasis.org/) | 工程代码: https://github.com/evan-taojiangcb/dream-castle-cinema  

---

## License

[MIT](./sdlc-workflow/LICENSE)
