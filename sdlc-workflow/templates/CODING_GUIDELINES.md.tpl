# Coding Guidelines

## Monorepo 落位规则

- Web 页面、路由、组件、前端状态逻辑默认放在 `apps/web/src/`
- 后端入口、路由、handler、service 默认放在 `apps/server/src/`
- 跨端共享类型、schema、工具、SDK、业务逻辑优先放在 `packages/*`
- 不要把同一份逻辑复制到 `apps/web` 和 `apps/server`
- 默认禁止新增根目录级 `web/`、`server/`、`api/`、`frontend/`、`backend/`
- 若需要新增新的 workspace，先在设计文档中声明，再实现

## 命名规范
<!-- 描述变量/函数/类/文件的命名规则 -->

## 代码风格
<!-- 描述缩进/格式化/注释规范 -->

## 错误处理
<!-- 描述异常处理和错误码策略 -->

## 测试规范
<!-- 描述测试覆盖率要求和测试编写规则 -->

## Git 规范
<!-- 描述分支策略和 Commit Message 格式 -->

## 代码审查
<!-- 描述 Code Review 标准和流程 -->

审查时额外检查：

- 文件是否落在正确 workspace
- 是否无必要地引入新的顶层目录
- 共享逻辑是否应该下沉到 `packages/*`
