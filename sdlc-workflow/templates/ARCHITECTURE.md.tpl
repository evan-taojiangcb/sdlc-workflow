# Architecture

## 系统概要
<!-- 请描述系统整体架构 -->

## 技术栈
<!-- 列出核心技术选型及版本 -->

## 目录约定

默认采用 Better-T-Stack 风格 monorepo：

```text
apps/
├── web/          # Web 前端
├── server/       # 后端 API / BFF / Worker
├── native/       # 移动端（可选）
└── docs/         # 文档站点（可选）

packages/
└── */            # 共享类型、工具、配置、SDK、业务模块
```

约束：

- Web UI 和页面逻辑默认放在 `apps/web/src/`
- 后端入口、路由、服务默认放在 `apps/server/src/`
- 共享逻辑优先进入 `packages/*`
- 默认不新增根目录级 `web/`、`server/`、`api/`、`frontend/`、`backend/`
- 若偏离该结构，必须记录原因和影响范围

## 模块结构
<!-- 描述主要模块及其职责 -->

建议至少说明：

- `apps/web` 负责什么
- `apps/server` 负责什么
- `packages/*` 中有哪些共享模块
- 哪些模块禁止跨层直接依赖

## 数据流
<!-- 描述数据如何在系统中流转 -->

## 外部依赖
<!-- 列出外部服务、API、数据库等 -->

## 部署架构
<!-- 描述部署环境和方式 -->

## 目录偏离记录
<!-- 若未采用上述 monorepo 结构，在这里记录原因、风险和后续迁移计划 -->
