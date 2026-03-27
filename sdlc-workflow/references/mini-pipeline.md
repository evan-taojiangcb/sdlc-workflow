# Mini Pipeline — 小任务强制执行顺序

## 目的

定义 `/sdlc-doit-mini` 的强制执行顺序，避免模型直接改代码而跳过：

- iteration 产物
- Gate 1
- validation capability detection
- Gate 2
- 最终浏览器验收

## 强制顺序

### Step 0. Preconditions

1. 项目必须已完成 `/sdlc-init`
2. 若缺少 baseline 文档且项目为 existing project，先回退执行 `/sdlc-init`
3. 判断是否满足 mini 条件；不满足立即升级到 `/sdlc-doit`

### Step 1. Create Iteration

必须先创建 iteration 目录，再做任何业务代码修改：

```text
docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/
```

### Step 2. Write requirements.md

要求：

1. 写明需求摘要
2. 写明影响范围
3. 写明验收条件
4. 标注 `Change Size: Micro`

### Step 3. Write design.md

要求：

1. 写明影响文件
2. 写明 `无架构变更`
3. 写明是否沿用 existing structure
4. 写明最终验收方式

### Step 4. Write tasks.md

要求：

1. 任务标题必须使用 `[ ]` / `[x]`
2. 至少包含：
   - 修改目标文件
   - 验证能力检测
   - 最终浏览器验收
   - 回写任务状态

### Step 5. Gate 1

在修改业务代码前，必须先做 mini Gate 1：

检查：

1. 是否真的属于 mini change
2. 是否无架构变更
3. 是否无目录结构调整
4. 是否目标文件范围足够小

若失败：

- 立即中止或升级到 `/sdlc-doit`

### Step 6. Implement

只有 Gate 1 通过后，才允许开始修改业务代码。

### Step 7. Validation Capability Detection

在 Gate 2 前必须检测：

1. lint 能力
2. unit test 能力
3. Playwright 预检能力
4. Chrome DevTools MCP 能力
5. WebMCP 能力

并输出到 mini 报告。

### Step 8. Gate 2

实现后必须做 mini Gate 2：

检查：

1. 修改是否越界
2. 是否误伤现有结构
3. `tasks.md` 是否已同步回写
4. 是否存在不必要的测试或基础设施改动

### Step 9. Final Validation

最终必须执行：

1. Playwright 预检（若适用）
2. Chrome DevTools MCP
3. WebMCP

最终通过结论只能由 Chrome DevTools MCP + WebMCP 给出。

### Step 10. Final Report

必须生成 mini 报告，至少包含：

1. Scope
2. Changed Files
3. Gate 1 result
4. Validation Capability Detection
5. Gate 2 result
6. Chrome DevTools MCP findings
7. WebMCP findings
8. Tasks status
9. Residual risks

## Hard Rules

1. 不得在 Step 1-4 之前直接编辑业务代码
2. 不得跳过 Gate 1
3. 不得跳过 validation capability detection
4. 不得跳过 Gate 2
5. 不得用“手工观察页面”替代最终 MCP 验收
