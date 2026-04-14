# 步骤 ②: Requirements Clarifier — 需求澄清（混合模式）

## 输入

`docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/requirements.md`

## 输出

更新后的 `docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/requirements.md`（带置信度标注）

## 详细行为

### 1. 置信度分析

对 requirements.md 中的每条需求进行置信度评估：

```javascript
// 置信度评分标准
const confidenceCriteria = {
  HIGH: 0.8,    // ≥0.8: 高置信度，直接确认
  MEDIUM: 0.5,  // 0.5-0.8: 中置信度，假设标注
  LOW: 0.5      // <0.5: 低置信度，TG 提问
};

// 评分因素
function assessConfidence(requirement) {
  let score = 0.5; // 基础分

  // 明确的业务价值 (+0.1)
  if (requirement.businessValue) score += 0.1;

  // 具体的技术描述 (+0.1)
  if (requirement.technicalSpec) score += 0.1;

  // 明确的验收标准，含 Given-When-Then (+0.15)
  if (requirement.acceptanceCriteria?.length > 0) score += 0.15;

  // 明确的依赖关系 (+0.05)
  if (requirement.dependencies) score += 0.05;

  // 需求边界清晰（有明确的 In/Out of Scope）(+0.1)
  if (requirement.scopeBoundaries) score += 0.1;

  // 模糊的描述 (-0.2)
  if (requirement.description.includes('...')) score -= 0.2;

  // 缺少边界条件描述 (-0.1)
  if (!requirement.edgeCases) score -= 0.1;

  // 缺少非功能性需求 (-0.05)
  if (!requirement.nfrs || requirement.nfrs.length === 0) score -= 0.05;

  return Math.max(0, Math.min(1, score));
}
```

### 2. 标注处理规则

| 置信度 | 条件 | 处理方式 | 标注标记 |
|--------|------|----------|----------|
| 高 | ≥0.8 | 直接确认，不阻塞流程 | `[✅ 已确认]` |
| 中 | 0.5-0.8 | 自行假设，不阻塞流程 | `[⚠️ 假设: <具体假设内容>]` |
| 低 | <0.5 | 标注假设 + TG 提问，不阻塞 | `[❓ 待确认: <问题>]` + TG 通知 |

### 3. 假设管理

```javascript
// 假设记录结构
const assumptions = {
  id: "ASM-001",
  requirement: "原始需求描述",
  assumption: "所做的假设内容",
  confidence: "medium | low",
  status: "pending | confirmed | rejected",
  confirmedBy: null, // TG 回复后填充
  confirmedAt: null
};
```

### 4. TG 提问策略

当存在低置信度需求时，通过 TG 向用户提问：

```bash
# 构建提问消息
QUESTIONS=$(cat << 'EOF'
❓ 以下需求需要您的确认：

1. [ASM-001] <问题1>
   已假设: <假设内容>
   原因: <为什么需要确认>

2. [ASM-002] <问题2>
   ...

请回复您的确认或修正。
EOF
)

openclaw message send \
  --channel telegram \
  --target "$TG_USERNAME" \
  --message "$QUESTIONS"
```

### 5. 更新 requirements.md

```markdown
## 需求详情

### 需求项 1
- **描述**: <需求描述>
- **置信度**: 高
- **标注**: [✅ 已确认]

### 需求项 2
- **描述**: <需求描述>
- **置信度**: 中
- **标注**: [⚠️ 假设: <假设内容>]
- **假设理由**: <为什么做出这个假设>

### 需求项 3
- **描述**: <需求描述>
- **置信度**: 低
- **标注**: [❓ 待确认: <问题>]
- **假设**: [⚠️ 假设: <假设内容>]

## 验收标准

<!-- 对步骤①生成的验收标准进行置信度审查 -->

### AC-001: <验收标准标题>
- **关联需求**: R-001
- **Given**: <前置条件>
- **When**: <用户操作/系统触发>
- **Then**: <期望结果>
- **验证方式**: unit | e2e | playwright-mcp | manual
- **置信度**: 高 [✅ 已确认]

### AC-002: <验收标准标题>
- **关联需求**: R-002
- **Given**: <前置条件>
- **When**: <用户操作/系统触发>
- **Then**: <期望结果> [⚠️ 假设: <期望结果的假设>]
- **验证方式**: e2e
- **置信度**: 中

## 需求边界

<!-- 澄清阶段补充或修正步骤①的边界判断 -->

### 包含 (In Scope)
- <确认后的事项>

### 不包含 (Out of Scope)
- <澄清后明确排除的事项>

## 假设记录

| ID | 关联 | 假设内容 | 状态 | 确认人 | 确认时间 |
|----|------|----------|------|--------|----------|
| ASM-001 | R-001 | ... | pending | - | - |
| ASM-002 | AC-002 | ... | pending | - | - |
| ASM-003 | NFR-001 | ... | pending | - | - |
```

## 命令模板

```bash
# 1. 读取 requirements.md
REQ_FILE="docs/iterations/$DATE/$SEQ-$SLUG-$TYPE/requirements.md"

# 2. 分析置信度
CLAUDE 分析每条需求，计算置信度

# 3. 分类处理
HIGH_CONF=$(jq -r '.requirements[] | select(.confidence >= 0.8)')
MEDIUM_CONF=$(jq -r '.requirements[] | select(.confidence >= 0.5 and .confidence < 0.8)')
LOW_CONF=$(jq -r '.requirements[] | select(.confidence < 0.5)')

# 4. 低置信度需求 → TG 提问
if [ -n "$LOW_CONF" ]; then
  openclaw message send \
    --channel telegram \
    --target "$TG_USERNAME" \
    --message "❓ 需确认: $(echo "$LOW_CONF" | jq -r '.question')"
fi

# 5. 更新 requirements.md
# 添加置信度标注和假设记录
```

## 错误处理

| 错误场景 | 处理方式 |
|----------|----------|
| requirements.md 不存在 | 回退到步骤①，重新执行 requirements-ingestion |
| 置信度分析失败 | 默认为中置信度，添加假设标注 |
| TG 通知发送失败 | 记录日志，继续执行（不阻塞） |
| 用户长时间未回复 | 流程继续，假设内容标记为 pending |

## TG 通知文案

### 需求澄清通知（低置信度时）

```
❓ 需确认以下问题（已标注假设，流程继续）：

[ASM-001] <问题1描述>
  假设: <假设内容>
  原因: <为什么需要确认>

[ASM-002] <问题2描述>
  假设: <假设内容>
  ...

请通过 TG 回复您的确认或修正。
```

## 相关文件

- 输入：requirements.md（原始）
- 输出：requirements.md（标注版，含假设记录）
- 参考：references/design-generator.md（下一步）
