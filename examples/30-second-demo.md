# 30-Second Demo Script

这个文档用于 GitHub 推广、录屏、推文或演示会议。目标不是讲完整实现细节，而是在 30 秒内让别人理解：

1. 这是一个能接入现有项目的 workflow
2. 它不是自由发挥，而是有 gate 和 evidence 的工程流程
3. 它最终用浏览器交互证据验收

## Demo Goal

推荐演示场景：

- 选一个 existing project
- 先执行 `init`
- 再执行一个 `mini` 需求
- 最后展示 iteration 产物、浏览器验收和 git commit

推荐需求：

```text
/sdlc-workflow mini 把首页背景改成黑色
```

这个需求足够小，能清楚展示：

- mini 流程
- 结构约束
- 最终浏览器验收

## 30 秒版本

### 开场一句话

> 这是一个给 Claude Code / OpenClaw 用的 SDLC workflow。它不是直接让模型改代码，而是先 intake、再设计、再 gate、最后用浏览器交互证据做验收。

### 演示步骤

1. 展示仓库目录

说明：

> 这是一个 existing project，不是空项目。workflow 不会先重建架构，而是先接入现有结构。

2. 运行初始化

```text
/sdlc-workflow init "tg=123456789 review=1"
```

说明：

> init 会自动识别这是 existing project，然后生成 baseline 文档和 workflow 配置。

3. 快速展示生成结果

重点展示：

- `docs/PROJECT_BASELINE.md`
- `docs/EXISTING_STRUCTURE.md`
- `docs/TEST_BASELINE.md`

说明：

> 这一步的作用是把现有结构固化成流程真相源，后面模型不能自由发挥打乱它。

4. 执行 mini 需求

```text
/sdlc-workflow mini 把首页背景改成黑色
```

说明：

> mini 不是跳过流程，它还是会生成 requirements、design、tasks，走 mini Gate 1 / Gate 2，最后做浏览器验收。

5. 展示 iteration 目录

重点展示：

```text
docs/iterations/YYYY-MM-DD/001-home-bg-black-fix/
```

说明：

> 每次变更都有 requirements、design、tasks，所以这不是一次性 prompt，而是一套可恢复、可追溯的迭代记录。

6. 展示最终验收产物

重点展示：

- `tests/reports/chrome/`
- `tests/reports/webmcp/`

说明：

> 最终通过不是靠模型说“我改好了”，而是靠 Chrome DevTools MCP 和 WebMCP 的浏览器交互证据。

7. 收尾

说明：

> 这套 workflow 适合 full-stack monorepo，尤其是 existing project 接入、微小需求治理和 AI 协作交付。

## 60-Second Expanded Version

如果你有 1 分钟，可以多补两点：

1. 目录 guardrails

说明：

> 它默认约束 `apps/web`、`apps/server`、`packages/*`，不会让模型随便新建根目录 `web/`、`api/`、`server/`。

2. 双模型 gate

说明：

> Claude 负责生成，Codex CLI 负责 Gate 1 和 Gate 2 审查。gate 失败不能静默跳过。
