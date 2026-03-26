# 步骤 ⑦: Test Generator — 测试用例生成

## 输入

1. `docs/iterations/YYYY-MM-DD/<slug>-<type>/tasks.md`
2. `git diff`（代码变更）

## 输出

1. `tests/unit/<slug>.test.ts`
2. `tests/e2e/<slug>.e2e.ts`
3. `tests/reports/<slug>-coverage.md`

## 详细行为

### 1. 测试文件生成原则

```
测试生成原则：
1. 单元测试覆盖每个任务的验收标准
2. E2E 测试覆盖关键用户场景
3. 测试文件直接写入 tests/ 对应子目录
4. 文件名使用 <slug> 前缀避免命名冲突
5. 使用 $TEST_FRAMEWORK 语法（jest/vitest）
6. 使用 $E2E_FRAMEWORK 语法（playwright/cypress）
```

### 2. 单元测试生成

```typescript
// tests/unit/<slug>.test.ts
// 使用 $TEST_FRAMEWORK 语法

import { describe, it, expect, beforeEach } from '$TEST_FRAMEWORK';
import { authService } from '../../src/services/authService';

describe('Auth Service', () => {
  let mockUser: TestUser;

  beforeEach(() => {
    mockUser = {
      id: 'test-id',
      username: 'testuser',
      email: 'test@example.com',
      password: 'hashed_password'
    };
  });

  describe('login', () => {
    it('should return token on valid credentials', async () => {
      // TODO: Implement test
    });

    it('should throw error on invalid password', async () => {
      // TODO: Implement test
    });

    it('should return 401 for non-existent user', async () => {
      // TODO: Implement test
    });
  });

  describe('validateToken', () => {
    it('should return user for valid token', async () => {
      // TODO: Implement test
    });

    it('should return null for expired token', async () => {
      // TODO: Implement test
    });
  });
});
```

### 3. E2E 测试生成

```typescript
// tests/e2e/<slug>.e2e.ts
// 使用 $E2E_FRAMEWORK 语法

import { test, expect } from '@playwright/test';

test.describe('User Authentication Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should show login form', async ({ page }) => {
    await expect(page.locator('input[name="username"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('should login with valid credentials', async ({ page }) => {
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    await expect(page.locator('.user-profile')).toBeVisible({ timeout: 5000 });
    await expect(page.locator('.user-profile')).toContainText('testuser');
  });

  test('should show error on invalid login', async ({ page }) => {
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expect(page.locator('.error-message')).toBeVisible();
    await expect(page.locator('.error-message')).toContainText('Invalid credentials');
  });
});
```

### 4. 测试覆盖度分析

生成测试覆盖度分析报告：

```markdown
# tests/reports/<slug>-coverage.md

# 测试覆盖度分析报告

## 基本信息

- **生成时间**: YYYY-MM-DD HH:mm:ss
- **迭代**: docs/iterations/<date>/<slug>-<type>/
- **测试框架**: $TEST_FRAMEWORK
- **E2E 框架**: $E2E_FRAMEWORK

## 单元测试覆盖

| 模块 | 覆盖率目标 | 覆盖的验收标准 |
|------|-----------|----------------|
| authService | 80%+ | 登录、登出、Token 验证 |
| userService | 70%+ | 用户 CRUD |
| sessionService | 75%+ | Session 管理 |

## E2E 测试覆盖

| 用户场景 | 测试用例 | 状态 |
|----------|----------|------|
| 用户登录 | 成功登录、失败登录 | ✅ |
| 用户登出 | 正常登出 | ✅ |
| Token 过期 | 自动刷新或跳转登录 | ⏳ |

## 待补充测试

### 边界条件
- [ ] 并发登录处理
- [ ] Token 竞争条件
- [ ] 数据库连接失败

### 异常场景
- [ ] 网络超时处理
- [ ] 服务不可用降级
- [ ] 恶意输入防护
```

### 5. 任务到测试的映射

```javascript
// 任务 → 测试用例映射
const taskTestMapping = {
  'T-001': ['test_user_login_success', 'test_user_login_invalid_password'],
  'T-002': ['test_session_creation', 'test_session_expiry'],
  'T-003': ['test_token_generation', 'test_token_validation']
};
```

## 命令模板

```bash
#!/bin/bash
set -euo pipefail

SLUG="$1"
ITER_DIR="docs/iterations/$DATE/$SLUG-$TYPE"
TASKS_FILE="$ITER_DIR/tasks.md"

# 读取测试框架配置
TEST_FRAMEWORK=${TEST_FRAMEWORK:-jest}
E2E_FRAMEWORK=${E2E_FRAMEWORK:-playwright}

# 1. 读取 tasks.md，提取验收标准
ACCEPTANCE_CRITERIA=$(cat "$TASKS_FILE" | grep -A 10 "验收标准")

# 2. 生成单元测试
cat > "tests/unit/${SLUG}.test.ts" << 'EOF'
// 单元测试 - 使用 $TEST_FRAMEWORK
import { describe, it, expect, beforeEach } from '$TEST_FRAMEWORK';
...
EOF

# 3. 生成 E2E 测试
cat > "tests/e2e/${SLUG}.e2e.ts" << 'EOF'
// E2E 测试 - 使用 $E2E_FRAMEWORK
import { test, expect } from '@playwright/test';
...
EOF

# 4. 生成覆盖度报告
cat > "tests/reports/${SLUG}-coverage.md" << 'EOF'
# 测试覆盖度分析报告
...
EOF

echo "✅ 测试用例生成完成"
ls -la tests/unit/${SLUG}.test.ts tests/e2e/${SLUG}.e2e.ts
```

## 错误处理

| 错误场景 | 处理方式 |
|----------|----------|
| tasks.md 不存在 | 回退到步骤④ |
| tests/ 目录不存在 | 自动创建 unit/e2e/reports 子目录 |
| 代码与测试不匹配 | 生成 TODO 标记，待 Claude Code 实现后补充 |
| 覆盖率目标未达成 | 在报告中标注，待后续迭代补充 |

## TG 通知文案

测试生成完成后：

```
🧪 测试用例已生成:
📂 tests/unit/<slug>.test.ts
📂 tests/e2e/<slug>.e2e.ts
📋 详见: tests/reports/<slug>-coverage.md
```

## 相关文件

- 输入：
  - docs/iterations/YYYY-MM-DD/<slug>-<type>/tasks.md
  - git diff（代码变更）
- 输出：
  - tests/unit/<slug>.test.ts
  - tests/e2e/<slug>.e2e.ts
  - tests/reports/<slug>-coverage.md
- 参考：
  - references/test-pipeline.md（下一步：测试执行）
  - references/code-reviewer.md（Gate 2）
