#!/bin/bash
set -euo pipefail

PROJECT_ROOT="${1:-.}"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# 检查是否已初始化
if [ -f "$PROJECT_ROOT/.claude/CLAUDE.md" ] && [ -f "$PROJECT_ROOT/docs/ARCHITECTURE.md" ]; then
  echo "✅ 项目已初始化，跳过"
  exit 0
fi

echo "🔧 初始化 SDLC Workflow 项目结构..."

# 创建目录（v7: 取消 specs/，统一 tests/）
mkdir -p "$PROJECT_ROOT/.claude/rules"
mkdir -p "$PROJECT_ROOT/docs/iterations"
mkdir -p "$PROJECT_ROOT/tests/unit"
mkdir -p "$PROJECT_ROOT/tests/e2e"
mkdir -p "$PROJECT_ROOT/tests/reports"

# 复制模板（不覆盖已存在的文件）
copy_if_not_exists() {
  [ -f "$2" ] || cp "$1" "$2"
}

copy_if_not_exists "$SKILL_DIR/templates/CLAUDE.md.tpl"              "$PROJECT_ROOT/.claude/CLAUDE.md"
copy_if_not_exists "$SKILL_DIR/templates/workflow-rules.md.tpl"      "$PROJECT_ROOT/.claude/rules/workflow-rules.md"
copy_if_not_exists "$SKILL_DIR/templates/ARCHITECTURE.md.tpl"        "$PROJECT_ROOT/docs/ARCHITECTURE.md"
copy_if_not_exists "$SKILL_DIR/templates/SECURITY.md.tpl"            "$PROJECT_ROOT/docs/SECURITY.md"
copy_if_not_exists "$SKILL_DIR/templates/CODING_GUIDELINES.md.tpl"   "$PROJECT_ROOT/docs/CODING_GUIDELINES.md"
copy_if_not_exists "$SKILL_DIR/templates/env.example.tpl"            "$PROJECT_ROOT/.env.example"

sync_env_var() {
  local file="$1"
  local key="$2"
  local value="$3"
  local tmp
  tmp="$(mktemp)"

  if [ -f "$file" ] && grep -q "^${key}=" "$file"; then
    awk -v key="$key" -v value="$value" '
      BEGIN { replaced = 0 }
      $0 ~ ("^" key "=") {
        print key "=" value
        replaced = 1
        next
      }
      { print }
      END {
        if (!replaced) {
          print key "=" value
        }
      }
    ' "$file" > "$tmp"
  else
    if [ -f "$file" ]; then
      cat "$file" > "$tmp"
      printf '\n%s=%s\n' "$key" "$value" >> "$tmp"
    else
      printf '%s=%s\n' "$key" "$value" > "$tmp"
    fi
  fi

  mv "$tmp" "$file"
}

# TG/OpenClaw 场景下自动创建 .env 并写入 TG_USERNAME
if [ -n "${OPENCLAW_TRIGGER_USER:-}" ]; then
  copy_if_not_exists "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
  sync_env_var "$PROJECT_ROOT/.env" "TG_USERNAME" "$OPENCLAW_TRIGGER_USER"
  echo "📱 检测到 TG 用户: @$OPENCLAW_TRIGGER_USER，已写入 .env"
fi

# 添加 .env 到 .gitignore
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  grep -q "^\.env$" "$PROJECT_ROOT/.gitignore" || echo ".env" >> "$PROJECT_ROOT/.gitignore"
else
  echo ".env" > "$PROJECT_ROOT/.gitignore"
fi

echo "✅ SDLC Workflow 项目初始化完成"
if [ -f "$PROJECT_ROOT/.env" ]; then
  echo "📝 已生成 .env，请检查其余配置项"
else
  echo "📝 请执行: cp .env.example .env && 编辑 .env 设置 TG_USERNAME"
fi
echo "📝 请编辑 .claude/CLAUDE.md 填写项目信息"
