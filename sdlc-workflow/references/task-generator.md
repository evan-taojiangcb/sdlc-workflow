# 步骤 ④: Task Generator — 任务分解

## 输入

`docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/design.md`

## 输出

`docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/tasks.md`

## 详细行为

### 1. 任务分解原则

将 design.md 中的设计方案拆解为可执行的任务：

```
分解原则：
1. 每个任务单一职责
2. 任务可独立测试
3. 任务有明确的验收标准
4. 任务有清晰的依赖关系
5. 复杂度评估准确
6. 任务必须明确落位到对应 workspace
7. 每个任务必须绑定 Requirement IDs，便于后续测试映射
8. 每个任务必须带显式完成状态，供执行阶段回写
```

### 2. 任务结构

每个任务包含以下字段：

```markdown
### [ ] T-001: <任务名称>

**描述**: <详细的任务描述>

**目标文件**:
- apps/server/src/routes/auth/login.ts
- packages/auth/src/index.ts

**Requirement IDs**:
- R-001
- R-003

**验收标准**:
- [ ] 用户可以成功登录
- [ ] 错误密码返回 401
- [ ] Token 正确返回

**依赖关系**:
- 前置任务: T-000（基础设施）

**复杂度**: M

**预估工时**: 2h
```

### 2.1 执行状态回写规则

`tasks.md` 不只是任务输入，也是执行状态单据。开发阶段完成任务后必须同步回写：

```markdown
### [x] T-001: <任务名称>
```

并且对应任务下的验收标准必须按真实完成情况勾选。若代码已经实现，但 `tasks.md` 仍保持未完成状态，Gate 2 必须视为流程不完整。

### 3. 复杂度评估标准

| 复杂度 | 说明 | 编码行数参考 |
|--------|------|--------------|
| S | 简单，独立文件，无依赖 | < 50 行 |
| M | 中等，涉及少量文件 | 50-150 行 |
| L | 复杂，多文件，依赖较多 | 150-300 行 |
| XL | 非常复杂，系统级变更 | > 300 行 |

### 4. 任务分组

按实施阶段对任务分组：

```markdown
## 任务分组

### Phase 1: 基础设施
| 任务 ID | 名称 | 复杂度 | 预估工时 |
|---------|------|--------|----------|
| T-001 | 数据库迁移 | M | 2h |
| T-002 | Redis 配置 | S | 1h |

### Phase 2: 核心功能
| 任务 ID | 名称 | 复杂度 | 预估工时 |
|---------|------|--------|----------|
| T-003 | 用户登录 API | M | 3h |
| T-004 | Token 生成 | M | 2h |

### Phase 3: 完善
| 任务 ID | 名称 | 复杂度 | 预估工时 |
|---------|------|--------|----------|
| T-005 | 单元测试 | L | 4h |
| T-006 | E2E 测试 | L | 4h |
```

### 5. 依赖关系图

```markdown
## 依赖关系图

```
T-001 ──┬── T-003 ──┬── T-005
        │           │
T-002 ──┘           │
                    │
              T-004 ──┴── T-006
```
```

### 6. 完整 tasks.md 模板

```markdown
# 任务分解文档

## 基本信息

- **迭代目录**: docs/iterations/<date>/<seq>-<slug>-<type>/
- **生成时间**: YYYY-MM-DD HH:mm:ss
- **基于设计**: design.md

## 任务总览

| Phase | 任务数 | 总工时 |
|-------|--------|--------|
| Phase 1: 基础设施 | 2 | 3h |
| Phase 2: 核心功能 | 3 | 7h |
| Phase 3: 完善 | 2 | 8h |
| **合计** | **7** | **18h** |

## Phase 1: 基础设施

### [ ] T-001: 数据库迁移

**描述**: 创建用户表和会话表，编写迁移脚本

**目标文件**:
- db/migrations/001_create_users.sql
- db/migrations/002_create_sessions.sql

**Requirement IDs**:
- R-001

**验收标准**:
- [ ] users 表创建成功
- [ ] sessions 表创建成功
- [ ] 索引正确创建

**依赖关系**: 无

**复杂度**: M

**预估工时**: 2h

---

### [ ] T-002: Redis 连接配置

**描述**: 配置 Redis 客户端，支持 Session 存储

**目标文件**:
- apps/server/src/lib/redis.ts
- packages/config/src/index.ts

**Requirement IDs**:
- R-001

**验收标准**:
- [ ] Redis 客户端可正常连接
- [ ] 连接池配置正确
- [ ] 错误处理完善

**依赖关系**: 无

**复杂度**: S

**预估工时**: 1h

---

## Phase 2: 核心功能

### [ ] T-003: 用户登录 API

**描述**: 实现用户登录接口，返回 JWT Token

**目标文件**:
- apps/server/src/routes/auth/login.ts
- apps/server/src/services/auth-service.ts
- packages/auth/src/session.ts

**Requirement IDs**:
- R-002
- R-003

**验收标准**:
- [ ] POST /api/auth/login 返回 Token
- [ ] 错误密码返回 401
- [ ] 不存在的用户返回 401

**依赖关系**: T-001, T-002

**复杂度**: M

**预估工时**: 3h

---

## Phase 3: 完善

### [ ] T-005: 单元测试

**描述**: 为核心模块编写单元测试

**目标文件**:
- tests/unit/auth.test.ts
- tests/unit/user.test.ts

**验收标准**:
- [ ] 覆盖率 > 80%
- [ ] 所有测试通过

**依赖关系**: T-003

**复杂度**: L

**预估工时**: 4h

---

## 任务执行顺序

1. T-001 → T-002（并行）
2. T-003 → T-004（串行，T-004 依赖 T-003）
3. T-005 → T-006（可并行测试）
```

## 命令模板

```bash
# 1. 读取 design.md
DESIGN_FILE="docs/iterations/$DATE/$SEQ-$SLUG-$TYPE/design.md"

# 2. 分析设计文档，提取任务
# - API 接口 → 实现任务
# - 数据模型 → 迁移任务
# - 安全考量 → 安全实现任务
# - 测试需求 → 测试任务
# - 目录影响声明 → workspace 落位任务

# 3. 生成任务 ID（T-001, T-002, ...）并绑定 Requirement IDs（R-001, R-002, ...）
TASK_ID="T-$(printf '%03d' $TASK_NUM)"

# 4. 写入 tasks.md
cat > "docs/iterations/$DATE/$SEQ-$SLUG-$TYPE/tasks.md" << 'TEMPLATE'
# 任务分解文档
...
TEMPLATE

# 5. 验证任务完整性
TOTAL_TASKS=$(grep -c "^### T-" "$TASKS_FILE")
echo "生成了 $TOTAL_TASKS 个任务"

# 6. TG 通知
TOTAL_HOURS=$(grep -oP '预估工时: \K[0-9]+' "$TASKS_FILE" | awk '{s+=$1}END{print s}')
notify_tg "📋 任务分解完成: $TOTAL_TASKS 个任务
⏱ 预估工时: ${TOTAL_HOURS}h
📂 详见: docs/iterations/$DATE/$SEQ-$SLUG-$TYPE/tasks.md"
```

## 错误处理

| 错误场景 | 处理方式 |
|----------|----------|
| design.md 不存在 | 回退到步骤③ |
| 设计过于笼统 | 提示用户补充设计细节 |
| 任务数超过 20 | 建议拆分为多个子需求 |

## TG 通知文案

任务生成完成后：

```
📋 任务分解完成: <任务总数> 个任务
⏱ 预估工时: <总工时>
📂 详见: docs/iterations/<date>/<seq>-<slug>-<type>/tasks.md
```

## 相关文件

- 输入：docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/design.md
- 输出：docs/iterations/YYYY-MM-DD/<seq>-<slug>-<type>/tasks.md
- 参考：
  - references/design-reviewer.md（下一步，Gate 1）
  - SKILL.md Part 4（任务执行阶段）
