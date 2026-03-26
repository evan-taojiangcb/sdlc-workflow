# 步骤 ⑤: Design Reviewer — Gate 1 设计审查

## 输入

1. `docs/iterations/YYYY-MM-DD/<slug>-<type>/design.md`
2. `docs/iterations/YYYY-MM-DD/<slug>-<type>/tasks.md`
3. `docs/ARCHITECTURE.md`
4. `docs/SECURITY.md`

## 输出

PASS 或 FAIL + 问题列表

## 详细行为

### 1. Codex CLI 调用

使用 Codex CLI 进行设计审查：

```bash
codex --approval-mode full-auto "审查以下设计文档和任务分解。

对照架构规范和安全规范检查:
1) 技术方案可行性
2) 安全设计完备性
3) 架构合规性
4) 任务分解完整性（边界条件/错误处理）
5) 数据模型合理性
6) 目录落位是否符合 Better-T-Stack 风格 monorepo

给出 PASS/FAIL 及具体问题列表。

=== design.md ===
$(cat docs/iterations/$DATE/$SLUG-$TYPE/design.md)

=== tasks.md ===
$(cat docs/iterations/$DATE/$SLUG-$TYPE/tasks.md)

=== ARCHITECTURE.md ===
$(cat docs/ARCHITECTURE.md)

=== SECURITY.md ===
$(cat docs/SECURITY.md)"
```

### 2. 审查维度

| 维度 | 检查项 | 通过标准 |
|------|--------|----------|
| 可行性 | 技术选型合理 | 无过度设计的超前技术 |
| 安全性 | 无安全漏洞 | 满足安全规范所有条目 |
| 架构合规 | 符合架构约定 | 无违反架构决策 |
| 完整性 | 边界条件处理 | 所有 API 有错误处理 |
| 数据模型 | 合理性 | 无数据冗余、关系清晰 |
| 目录结构 | workspace 落位正确 | Web 在 `apps/web`，Server 在 `apps/server`，共享逻辑在 `packages/*` |

### 3. 循环逻辑

```bash
round=1
max_rounds=${REVIEW_MAX_ROUNDS:-3}

while [ $round -le $max_rounds ]; do
  echo "🔍 设计 Review 第 $round 轮..."

  # 调用 Codex 审查
  result=$(codex --approval-mode full-auto "$PROMPT")

  if echo "$result" | grep -qiE "^PASS$|^\*\*结论\*\*: PASS$|^结论: PASS$"; then
    echo "✅ 设计审查通过"
    notify_tg "🔍 设计 Review: PASS ✅"
    exit 0
  else
    # 提取问题列表
    issues=$(echo "$result" | grep -A 100 "问题列表" || echo "$result")

    if [ $round -lt $max_rounds ]; then
      echo "⚠️ 设计审查失败，第 $round 轮问题："
      echo "$issues"

      notify_tg "🔍 设计 Review 第${round}轮: $(echo "$issues" | head -c 200)..."

      # Claude Code 根据反馈修订
      echo "📝 Claude Code 修订 design.md + tasks.md..."
      # ... 修订逻辑 ...

    else
      echo "❌ 设计审查超过 $max_rounds 轮，需人工介入"
      notify_tg "⚠️ 设计 Review 超过 ${max_rounds} 轮，需人工介入 → 中止 Pipeline"
      exit 1
    fi
  fi

  round=$((round + 1))
done
```

### 4. 审查报告格式

Codex 返回格式：

```
## 审查结果

**结论**: PASS | FAIL

## 问题列表

### 问题 1: [安全] Token 过期时间过长
- **严重性**: 高
- **位置**: design.md 第 5 节
- **描述**: 当前 Token 过期时间为 30 天，建议缩短到 24 小时
- **建议**: 将 expires_in 从 '30d' 改为 '24h'

### 问题 2: [完整性] 缺少错误处理
- **严重性**: 中
- **位置**: tasks.md T-003
- **描述**: 登录 API 缺少网络超时处理
- **建议**: 添加 try-catch 和超时处理

...
```

## 命令模板

```bash
#!/bin/bash
set -euo pipefail

ITER_DIR="docs/iterations/$DATE/$SLUG-$TYPE"
DESIGN_FILE="$ITER_DIR/design.md"
TASKS_FILE="$ITER_DIR/tasks.md"
ARCH_FILE="docs/ARCHITECTURE.md"
SEC_FILE="docs/SECURITY.md"

round=1
max_rounds=${REVIEW_MAX_ROUNDS:-3}

while [ $round -le $max_rounds ]; do
  echo "🔍 设计 Review 第 $round 轮..."

  PROMPT="$(cat <<EOF
审查以下设计文档和任务分解。

对照架构规范和安全规范检查:
1) 技术方案可行性
2) 安全设计完备性
3) 架构合规性
4) 任务分解完整性（边界条件/错误处理）
5) 数据模型合理性
6) 目录落位是否符合 Better-T-Stack 风格 monorepo

给出 PASS/FAIL 及具体问题列表。

=== design.md ===
$(cat "$DESIGN_FILE")

=== tasks.md ===
$(cat "$TASKS_FILE")

=== ARCHITECTURE.md ===
$(cat "$ARCH_FILE")

=== SECURITY.md ===
$(cat "$SEC_FILE")
EOF
)"
  result=$(codex --approval-mode full-auto "$PROMPT")

  if echo "$result" | grep -qiE "^PASS$|^\*\*结论\*\*: PASS$|^结论: PASS$"; then
    echo "✅ 设计审查通过"
    exit 0
  fi

  if [ $round -eq $max_rounds ]; then
    echo "❌ 设计审查超过 $max_rounds 轮，需人工介入"
    exit 1
  fi

  echo "⚠️ 设计审查失败，修订中..."
  # Claude 修订 design.md + tasks.md

  round=$((round + 1))
done
```

## 错误处理

| 错误场景 | 处理方式 |
|----------|----------|
| Codex CLI 不可用 | 立即中止 Pipeline，通知人工介入 |
| 审查超时 | 重试最多 3 次，仍失败则中止 |
| .env 未设置 | 使用默认 max_rounds=3 |
| 设计文档不存在 | 回退到步骤③ |
| 目录结构偏离默认约定 | FAIL，回退到步骤③补充目录影响声明 |

## TG 通知文案

### 审查通过

```
🔍 设计 Review: PASS ✅
📋 <通过轮数> 轮审查通过
📂 设计文档已确认
```

### 审查失败（循环中）

```
🔍 设计 Review 第 {N} 轮: <问题摘要前100字>
📝 Claude 正在修订，请稍候...
```

### 审查超限

```
⚠️ 设计 Review 超过 {N} 轮，需人工介入
📂 保留当前所有产物待人工修复
💡 修复后可从步骤③手动恢复
```

## 相关文件

- 输入：
  - design.md
  - tasks.md
  - docs/ARCHITECTURE.md
  - docs/SECURITY.md
- 输出：审查结果（PASS/FAIL）
- 参考：
  - SKILL.md Part 4（下一步：步骤⑥ Claude Code 开发）
  - references/code-reviewer.md（Gate 2）
