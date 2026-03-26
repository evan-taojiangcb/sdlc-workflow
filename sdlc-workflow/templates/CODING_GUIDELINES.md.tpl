# Coding Guidelines

## Monorepo 落位规则

- Web 页面、路由、组件、前端状态逻辑默认放在 `apps/web/src/`
- 后端入口、路由、handler、service 默认放在 `apps/server/src/`
- 跨端共享类型、schema、工具、SDK、业务逻辑优先放在 `packages/*`
- 不要把同一份逻辑复制到 `apps/web` 和 `apps/server`
- 默认禁止新增根目录级 `web/`、`server/`、`api/`、`frontend/`、`backend/`
- 若需要新增新的 workspace，先在设计文档中声明，再实现
- Better-T-Stack 包布局按能力启用：
  - `packages/config` 总是存在
  - `packages/env`：存在前端或后端时
  - `packages/api`：启用 API 层时
  - `packages/auth`：启用认证时
  - `packages/db`：启用数据库 + ORM 时
  - `packages/infra`：启用 Cloudflare / infra 时
  - `packages/ui`：React Web 共享 UI 时

## 命名规范
<!-- 描述变量/函数/类/文件的命名规则 -->

## 代码风格
<!-- 描述缩进/格式化/注释规范 -->

## 错误处理
<!-- 描述异常处理和错误码策略 -->

## 测试规范
- 单元测试必须放在 `tests/unit/`，按 workspace 镜像目录组织，不得与源码混放
- `apps/web/src/logic/calculator.ts` 对应 `tests/unit/web/logic/calculator.test.ts`
- `apps/server/src/routes/calc.ts` 对应 `tests/unit/server/routes/calc.test.ts`
- `packages/api/src/client.ts` 对应 `tests/unit/packages/api/client.test.ts`
- E2E 测试必须放在 `tests/e2e/<slug>/`
- 每个 E2E 文件必须带唯一场景 ID，如 `E2E-001`
- 每个 E2E 文件必须注明覆盖的 Requirement IDs 和 Task IDs
- 同一需求路径不得被重复创建多个等价 E2E 场景；若已有场景覆盖，应扩展原文件或显式记录替代关系
- E2E 结果报告必须包含 Chrome DevTools MCP 的验证证据

## Git 规范
<!-- 描述分支策略和 Commit Message 格式 -->

## 代码审查
<!-- 描述 Code Review 标准和流程 -->

审查时额外检查：

- 文件是否落在正确 workspace
- 是否无必要地引入新的顶层目录
- 共享逻辑是否应该下沉到 `packages/*`
- 测试是否错误写入源码目录
