# SDLC Workflow Suite Design

## 1. Overview

`SDLC Workflow Suite` 是一套围绕 Claude Code / OpenClaw 使用场景设计的自动化软件交付流程。它解决的问题不是“怎么让模型多写代码”，而是“怎么让模型在真实工程里少跑偏、可审计、可恢复、可推广”。

本仓库当前的稳定产品形态是：

```text
/sdlc-workflow
/sdlc-workflow init ...
/sdlc-workflow doit ...
/sdlc-workflow mini ...
```

它背后的设计决策是：

- 用单入口降低技能注册复杂度
- 用子命令明确流程分工
- 用共享规则收束结构、审查、测试和交付
- 用 evidence-first 模式避免 handoff 文档污染事实

这个设计文档面向两类读者：

1. 想理解整体产品形态和流程的使用者
2. 想二次开发或推广该技能的维护者

---

## 2. Problem Statement

在实际使用 AI 做开发自动化时，最常见的问题不是“模型不会写代码”，而是下面这些工程偏差：

1. 老项目被当成新项目处理
2. 模型擅自新建目录或重排 workspace
3. 设计文档与代码事实脱节
4. 审查 gate 工具调用失败后被静默跳过
5. 测试报告与真实文件、真实命令不一致
6. 微小需求被过度工程化，或者完全绕过流程
7. 会话中断后无法恢复，依赖模型记忆继续
8. 远程 / TG / OpenClaw 场景下无法靠多轮追问完成初始化

这套系统的设计目标，就是把这些问题变成明确的工程 contract。

---

## 3. Product Positioning

### 3.1 What It Is

它是一套：

- 以 skill 为入口的流程编排系统
- 以文件、规则、脚本、审查 gate 为基础设施
- 面向 full-stack monorepo 的 AI SDLC 自动化套件

### 3.2 What It Is Not

它不是：

- 单次 prompt 模板合集
- 只会生成代码的 coding agent
- 一套依赖模型“自己懂项目结构”的松散工作流
- 单纯面向空项目脚手架的 generator

### 3.3 Target Project Type

默认主要面向：

- Better-T-Stack 风格 monorepo
- `apps/web + apps/server + packages/*`
- 既有项目的增量开发与接入
- 需要文档、审查、测试、Git 交付闭环的团队

---

## 4. Why Single Entry + Subcommands

这个仓库曾经尝试把命令拆成：

- `/sdlc-init`
- `/sdlc-doit`
- `/sdlc-doit-mini`

从产品语义上，这是合理的。但在部分运行环境里出现了一个关键问题：

- 新增 slash skill 不一定会被当前会话热加载
- 文件系统里就算已经存在 `SKILL.md`
- 运行器也可能继续报 `Unknown skill`

这意味着“多入口 slash 命令”在推广时会遇到环境兼容问题。

因此当前推荐产品形态收束为：

```text
/sdlc-workflow init ...
/sdlc-workflow doit ...
/sdlc-workflow mini ...
```

这样做有 4 个好处：

1. 复用已经稳定可识别的 skill 名称
2. 降低新用户安装和注册成本
3. 子命令语义仍然清楚
4. 可以保留分入口实现，但对外统一宣传单入口

---

## 5. Product Surface

### 5.1 `sdlc-workflow init`

用途：

- 初始化 fresh project
- 接入 existing project
- 写入最小 workflow 配置
- 为后续流程建立 baseline

输入：

- 可无参数
- 可带自然语言 prompt
- 可带最小键值，如 `tg=@name review=1 test-bootstrap=report`

输出：

- `.claude/CLAUDE.md`
- `.claude/rules/workflow-rules.md`
- `.env.example`
- `docs/ARCHITECTURE.md`
- `docs/SECURITY.md`
- `docs/CODING_GUIDELINES.md`
- 或 existing project 的 baseline 文档

### 5.2 `sdlc-workflow doit`

用途：

- 处理标准 feature / fix / refactor / docs / test 需求
- 走完整 requirements -> design -> tasks -> gate -> test -> docs -> git 流程

### 5.3 `sdlc-workflow mini`

用途：

- 处理微小需求
- 保持最小文档、最小实现、最小测试
- 但不能跳过结构约束和最终浏览器验收

适合：

- 改背景色
- 改文案
- 调样式
- 小 UI 修复

不适合：

- API 变更
- 数据模型变更
- workspace 改造
- 跨模块重构

---

## 6. System Principles

### 6.1 Structure Before Intelligence

模型不应该自己决定工程结构。结构规则必须由 workflow 明确给出。

默认约束：

- `apps/web`
- `apps/server`
- `packages/config`
- 条件启用 `packages/env|api|auth|db|infra|ui`

默认禁止模型无依据创建：

- `web/`
- `server/`
- `api/`
- `frontend/`
- `backend/`

### 6.2 Existing Project First

真实世界里，大部分项目不是 fresh project，而是 existing project。

因此系统默认必须优先支持：

- 自动识别 existing project
- 自动分析技术栈与目录结构
- 先 intake，再做需求

### 6.3 Evidence First

任何“完成”“通过”“一致”的结论，都必须有证据。

证据来源包括：

- 真实文件
- 真实命令输出
- 真实测试结果
- 真实浏览器交互验收

### 6.4 Gates Cannot Silently Downgrade

Gate 失败不能偷偷变成“人工简单看一下算通过”。

如果 Codex 审查失败、命令错误或工具问题：

- 必须记录原始错误
- 必须中止或进入人工介入
- 不能伪造 `PASS`

### 6.5 Remote-Friendly by Default

OpenClaw / TG 场景不适合多轮 ask。

因此：

- init 优先自动分析
- 只收最少配置
- 测试基础设施策略使用 `report|auto|never`
- default for existing project 是 `report`

---

## 7. Operational Modes

### 7.1 Fresh Project Mode

触发条件：

- 项目目录基本为空
- 缺少业务代码和工程脚手架

行为：

1. 初始化项目基础结构
2. 生成 workflow 文档模板
3. 创建测试目录
4. 建立配置文件模板
5. 进入后续 full flow

### 7.2 Existing Project Mode

触发条件：

- 已存在 `package.json`、`.git`、`apps/`、`packages/`、`src/`、`turbo.json` 等工程结构

行为：

1. 不重建目录
2. 自动分析现有结构和脚本
3. 生成 baseline 文档：
   - `docs/PROJECT_BASELINE.md`
   - `docs/EXISTING_STRUCTURE.md`
   - `docs/TEST_BASELINE.md`
4. 后续需求设计必须引用 baseline

### 7.3 Micro Change Mode

触发条件：

- 影响范围很小
- 不涉及架构与协议层变化
- 目标文件和影响边界可控

行为：

1. 使用精简 `requirements.md`
2. 使用精简 `design.md`
3. 使用精简 `tasks.md`
4. 仍执行 mini Gate 1 / Gate 2
5. 最终以浏览器交互验收为准

---

## 8. Architecture

### 8.1 Two-Layer Design

系统分成两层：

1. Skill Repository Layer
2. Project Runtime Layer

```text
┌────────────────────────────────────────────────────┐
│ Skill Repository Layer                             │
│                                                    │
│ sdlc-workflow/SKILL.md                             │
│ references/*.md                                    │
│ templates/*.tpl                                    │
│ scripts/*.sh                                       │
└───────────────────────┬────────────────────────────┘
                        │ initialize / enforce
┌───────────────────────▼────────────────────────────┐
│ Project Runtime Layer                              │
│                                                    │
│ .claude/                                           │
│ docs/                                              │
│ docs/iterations/                                   │
│ tests/unit / tests/e2e / tests/reports/            │
│ apps/web / apps/server / packages/*                │
└────────────────────────────────────────────────────┘
```

### 8.2 Shared Core

共享核心由这几部分组成：

- `references/`
  - step contract
  - gate contract
  - intake contract
  - test pipeline contract
- `templates/`
  - workflow 文档模板
  - `.env.example`
  - 规则模板
- `scripts/`
  - `init-project.sh`
  - `update-workflow-config.sh`

### 8.3 Project Runtime Artifacts

运行时最关键的产物包括：

- `docs/ARCHITECTURE.md`
- `docs/SECURITY.md`
- `docs/CODING_GUIDELINES.md`
- `docs/PROJECT_BASELINE.md`
- `docs/EXISTING_STRUCTURE.md`
- `docs/TEST_BASELINE.md`
- `docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/`
- `tests/reports/chrome/`
- `tests/reports/webmcp/`

---

## 9. Iteration Model

### 9.1 Naming Rule

每轮需求产物固定进入：

```text
docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/
```

示例：

```text
docs/iterations/2026-03-27/001-home-bg-black-fix/
docs/iterations/2026-03-27/002-login-api-feature/
```

### 9.2 Why Sequence Matters

只用日期和 slug 不够，因为：

- 同一天可以有多个需求
- 需求顺序本身是重要上下文
- 恢复流程时需要知道执行顺位

因此 `<seq>` 是强制项，不是装饰项。

---

## 10. Workflow Contracts

### 10.1 Standard Flow

完整流程是 12 步：

1. initialization
2. requirements ingestion
3. requirements clarifier
4. design generator
5. task generator
6. Gate 1 design review
7. implementation
8. test generation
9. Gate 2 code review
10. test pipeline
11. docs update
12. git delivery

### 10.2 Mini Flow

mini 流程是轻量流程，但不是自由改代码：

1. initialization check
2. mini requirements
3. mini design
4. mini tasks
5. mini Gate 1
6. implementation
7. validation capability detection
8. mini Gate 2
9. Chrome DevTools MCP + WebMCP acceptance
10. mini report + git commit

### 10.3 Initialization Contract

`init` 执行时必须先判断项目类型：

- fresh
- existing

existing project 下：

- 不允许重新搭脚手架
- 不允许重排 workspace
- 不允许擅自替换现有构建方式

---

## 11. Review and Gate Design

### 11.1 Gate 1

Gate 1 审查对象：

- `requirements.md`
- `design.md`
- `tasks.md`
- baseline 文档
- 目录落位与架构边界

### 11.2 Gate 2

Gate 2 审查对象：

- 实际代码改动
- `tasks.md` 勾选状态
- 测试生成与报告引用
- 文档与实现一致性

### 11.3 Codex Invocation

系统已经修正过期命令，当前应使用：

```bash
codex exec --full-auto "<prompt>"
```

不再使用无效的：

```bash
codex --approval-mode full-auto
```

### 11.4 Failure Policy

如果 Codex 审查失败：

- 记录原始 stderr
- 允许按 review round 重试
- 达到上限后中止
- 不允许写成“工具不可用所以人工跳过”

---

## 12. Testing Strategy

### 12.1 Test Chain

标准链路：

```text
lint -> unit -> Playwright precheck -> Chrome DevTools MCP -> WebMCP
```

### 12.2 Final Acceptance Standard

最终通过结论只能基于：

```text
Chrome DevTools MCP + WebMCP
```

Playwright 只是预检，不是最终通过依据。

### 12.3 Existing Project Bootstrap Policy

对 existing project，测试基础设施不应默认静默安装。

因此加入：

```text
TEST_BOOTSTRAP_POLICY=report|auto|never
```

推荐默认：

- existing project: `report`

含义：

- `report`：检测缺口，写报告，不自动装
- `auto`：允许自动补齐基础设施
- `never`：缺什么都不装，只报告并阻塞

### 12.4 Mini Test Semantics

mini 任务下：

- unit test 不是永远强制
- 但最终浏览器验收是强制的
- 如果浏览器验收无法执行，任务不能宣告完成

---

## 13. Evidence Model

### 13.1 Evidence Classes

所有陈述分两类：

- `Verified`
- `Claimed`

### 13.2 Verified Means

必须由以下至少一种支持：

- 文件存在
- 命令结果
- 测试报告
- 截图或浏览器产物

### 13.3 Claimed Means

来自：

- handoff 叙述
- memory 文档
- 模型归纳
- 人工口头说明

如果没有文件和命令支撑，不能升级成 `Verified`。

---

## 14. OpenClaw / TG Considerations

### 14.1 Why Ask-Heavy Design Fails

远程控制场景经常存在这些问题：

- 输入回合少
- ask 可能无法完整回传
- 执行链路长
- 人在手机端很难来回填参数

### 14.2 Current Design Response

因此系统采用：

- auto-detect first
- prompt parsing second
- defaulting third
- blocking only when truly necessary

对于 existing project，`init` 通常只需要用户补：

- `TG_USERNAME`
- `REVIEW_MAX_ROUNDS`
- 可选 `TEST_BOOTSTRAP_POLICY`

---

## 15. Distribution Strategy

### 15.1 Current Practical Packaging

当前最稳的分享方式不是依赖多个新增 slash skill，而是：

1. 分发 `sdlc-workflow`
2. 在技能目录安装或软链
3. 通过单入口子命令对外暴露功能

### 15.2 Why This Is Promotion-Friendly

这对 GitHub 推广更友好，因为：

- 安装步骤更短
- 对运行器兼容性要求更低
- 文档更容易讲清楚
- 用户只需要记住一个命令名字

### 15.3 Recommended GitHub Promotion Shape

推荐 GitHub 仓库首页结构：

1. `README.md`
   - 项目定位
   - 核心特性
   - 快速开始
   - 核心命令
   - 截图 / 示例
2. `DESIGN.md`
   - 详细设计
   - 工作流 contract
   - 架构图
   - 测试策略
3. `examples/` 或演示仓库
   - fresh project example
   - existing project example
4. `CHANGELOG.md`
5. `LICENSE`

---

## 16. Roadmap

### 16.1 Short Term

- 根 README 对齐单入口模式
- 补项目级本地安装说明
- 增加 GitHub 推广素材
- 补真实演示脚本

### 16.2 Mid Term

- 兼容矩阵：不同运行器如何加载 skill
- 示例项目与标准演练报告
- 发布版目录整理
- 自动 doctor / diagnose 脚本

### 16.3 Long Term

- 发布版插件化
- 项目级局部安装方案
- CI 集成模式
- 可视化状态追踪

---

## 17. Summary

这套系统的核心不是“AI 自动写代码”，而是三件事：

1. 用可执行 contract 收束模型偏差
2. 用 evidence-first 保证结论可信
3. 用单入口多模式降低实际落地和推广成本

当前最适合对外宣传的产品心智应该是：

> 一个面向 real-world full-stack projects 的 AI SDLC workflow。  
> 它能接入 existing project，约束结构漂移，保留完整 iteration 产物，并以浏览器交互证据作为最终验收依据。
