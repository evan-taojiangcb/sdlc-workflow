# 步骤 ①: Requirements Ingestion — 需求采集与路由

## 输入

`/sdlc-workflow` 的参数，接受三种格式：

| 格式 | 示例 | 处理方式 |
|------|------|----------|
| 纯文本 | `创建一个用户登录模块` | 直接作为需求内容 |
| file:// 路径 | `file:///path/to/requirements.txt` | 读取本地文件 |
| URL | `https://jira.company.com/browse/PROJ-123` | Playwright MCP 提取 |

## 输出

`docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/requirements.md`

## 详细行为

### 1. 输入类型判断

```bash
INPUT="$1"

if [[ "$INPUT" == file://* ]]; then
  # 读取本地文件
  CONTENT=$(cat "${INPUT#file://}")
  TYPE="local_file"
elif [[ "$INPUT" == http://* ]] || [[ "$INPUT" == https://* ]]; then
  # URL 提取
  TYPE="url"
  # 使用 Playwright MCP 打开 URL 并提取内容
  # 详见 Playwright MCP 文档
else
  # 纯文本
  CONTENT="$INPUT"
  TYPE="text"
fi
```

### 2. Slug 生成规则

从需求内容生成稳定、可读、语言无关的 slug：

- 优先让 Claude 根据需求摘要生成一个英文 kebab-case slug
- 最长 30 个字符
- 若需求主要是中文或其他非 ASCII 内容，导致清洗后为空，则回退到 `req-<hash8>`
- slug 只负责稳定标识，不要求和原文逐字对应

```bash
SLUG_CANDIDATE="$(echo "$CONTENT" | \
  tr '[:upper:]' '[:lower:]' | \
  sed 's/[^a-z0-9 ]//g' | \
  tr -s ' ' '-' | \
  cut -c1-30 | \
  sed 's/^-*//; s/-*$//')"

if [ -n "$SLUG_CANDIDATE" ]; then
  SLUG="$SLUG_CANDIDATE"
else
  HASH="$(printf '%s' "$CONTENT" | shasum | cut -c1-8)"
  SLUG="req-$HASH"
fi
```

### 3. 变更类型推断

根据需求内容关键词推断变更类型：

| 类型 | 关键词 | 说明 |
|------|--------|------|
| feature | add, new, create, implement, 功能, 新增 | 新功能 |
| fix | fix, bug, patch, 修复, 解决 | Bug 修复 |
| refactor | refactor, optimize, improve, 重构, 优化 | 重构优化 |
| docs | docs, documentation, 文档 | 文档更新 |
| test | test, testing, 测试 | 测试相关 |
| chore | chore, setup, config, 配置, 部署 | 维护任务 |

```bash
TYPE="feature"  # 默认值
if echo "$CONTENT" | grep -qiE "(fix|bug|patch|修复|解决)"; then
  TYPE="fix"
elif echo "$CONTENT" | grep -qiE "(refactor|optimize|improve|重构|优化)"; then
  TYPE="refactor"
elif echo "$CONTENT" | grep -qiE "(docs?|文档)"; then
  TYPE="docs"
elif echo "$CONTENT" | grep -qiE "(test|测试)"; then
  TYPE="test"
elif echo "$CONTENT" | grep -qiE "(chore|setup|config|配置|部署)"; then
  TYPE="chore"
fi
```

### 4. 顺序号生成

同一天内的 iteration 目录必须带递增序号，保证执行顺序可追踪且按字典序可排序：

```bash
DATE=$(date +%Y-%m-%d)
DATE_DIR="docs/iterations/$DATE"
mkdir -p "$DATE_DIR"

LAST_SEQ=$(find "$DATE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | \
  sed -n 's/^\([0-9][0-9][0-9]\)-.*/\1/p' | sort | tail -n1)

if [ -n "$LAST_SEQ" ]; then
  SEQ=$(printf "%03d" $((10#$LAST_SEQ + 1)))
else
  SEQ="001"
fi
```

### 5. 目录创建

```bash
ITER_DIR="docs/iterations/$DATE/${SEQ}-${SLUG}-${TYPE}/"
mkdir -p "$ITER_DIR"
```

### 6. 需求文档写入

创建 `requirements.md`，包含：

```markdown
# 需求文档

## 基本信息

- **采集时间**: YYYY-MM-DD HH:mm:ss
- **迭代序号**: <seq>
- **输入类型**: text | file | url
- **变更类型**: feature | fix | refactor | docs | test | chore
- **Slug**: <slug>

## 原始需求

<需求内容原文>

## 需求摘要

<50字内的需求摘要>

## 需求详情

<结构化需求详情>

建议为需求详情中的每条核心能力分配 Requirement ID：

- R-001: <核心能力 1>
- R-002: <核心能力 2>
- R-003: <核心能力 3>

## 外部依赖

<!-- 如有外部文档/JIRA 链接，在此标注 -->
- 来源: <URL 或 文件路径>
- 内容摘要: <提取的关键信息>

## 假设标注

<!-- 在澄清环节填充 -->
```

### 7. 外部文档拉取

检测需求中是否指定了外部文档来源：

```bash
# 检测 URL/文件引用
if echo "$CONTENT" | grep -qE "(https?://|file://)"; then
  # 提取并拉取外部文档
  # 更新 docs/ARCHITECTURE.md / SECURITY.md / CODING_GUIDELINES.md
fi
```

### 8. TG 通知

```bash
openclaw message send \
  --channel telegram \
  --target "$TG_USERNAME" \
  --message "[项目名] 📥 需求已收录: $(echo "$CONTENT" | head -c 50)..."
```

## 命令模板

```bash
# 1. 判断输入类型
case "$INPUT_TYPE" in
  text)
    CONTENT="$INPUT"
    ;;
  file)
    CONTENT=$(cat "${INPUT#file://}")
    ;;
  url)
    # 使用 Playwright MCP 打开页面并提取正文摘要
    # 不要调用不存在的 mcp__chrome_devtools__extract
    CONTENT="<从页面可见正文提取的结构化摘要>"
    ;;
esac

# 2. 生成 slug 和 type
SLUG=$(generate_slug "$CONTENT")
TYPE=$(infer_type "$CONTENT")

# 3. 创建目录
DATE=$(date +%Y-%m-%d)
DATE_DIR="docs/iterations/$DATE"
mkdir -p "$DATE_DIR"
LAST_SEQ=$(find "$DATE_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | \
  sed -n 's/^\([0-9][0-9][0-9]\)-.*/\1/p' | sort | tail -n1)
if [ -n "$LAST_SEQ" ]; then
  SEQ=$(printf "%03d" $((10#$LAST_SEQ + 1)))
else
  SEQ="001"
fi
ITER_DIR="$DATE_DIR/${SEQ}-${SLUG}-${TYPE}/"
mkdir -p "$ITER_DIR"

# 4. 写入 requirements.md
cat > "$ITER_DIR/requirements.md" << 'EOF'
...
EOF

# 5. TG 通知
notify_tg "📥 需求已收录: $(echo "$CONTENT" | head -c 50)..."
```

## 错误处理

| 错误场景 | 处理方式 |
|----------|----------|
| 文件不存在 (file://) | 记录日志，提示用户检查路径 |
| URL 无法访问 | 记录日志，保留 URL 引用待人工处理 |
| Playwright MCP 失败 | 降级为手动复制粘贴，提示用户 |
| 目录创建失败 | 中止 Pipeline，提示权限问题 |
| TG 通知发送失败 | 只记录日志，继续执行 |

## TG 通知文案

**需求收录通知**：
```
📥 需求已收录: <需求摘要前50字>
📂 迭代目录: docs/iterations/<date>/<seq>-<slug>-<type>/
```

## 相关文件

- 输入：用户提供的需求（文本/文件/URL）
- 输出：docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/requirements.md
- 参考：references/requirements-clarifier.md（下一步）
