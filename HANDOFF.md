# SDLC Workflow Skill — Codex 审查交接文档

## 项目背景

构建一个 **AI 24H Digital Worker Virtual Office** 的自动化 SDLC 工作流技能，基于：
- Google Cloud 5 种 Agent 设计模式（Sequential Chain / Routing / Parallelization / Orchestrator-Workers / Evaluator-Optimizer）
- Claude Code Skills 架构（用户级 Skill，`~/.agents/skills/sdlc-workflow/`）
- 双模型把关（Claude Code 生成，Codex CLI 审查）

## 设计文档

- **plan-7.md** — 完整 v7 设计文档（最终版），包含所有架构决策和实施细节

## 关键设计决策（必须保留）

1. **双模型把关不可移除** — Gate 1（design-reviewer）+ Gate 2（code-reviewer），均通过 `codex --approval-mode full-auto` 调用
2. **用户级元 Skill** — 安装到 `~/.agents/skills/sdlc-workflow/`，不是项目级 `.claude/skills/`
3. **入口命令 `/sdlc-workflow`** — 不是 `/start-workflow`
4. **统一 tests/ 目录** — 无独立 specs/ 目录，AI 生成的测试直接写入 `tests/unit/` 和 `tests/e2e/`
5. **迭代目录格式** — `docs/iterations/YYYY-MM-DD/<slug>-<type>/`（如 `user-login-feature/`）
6. **CLAUDE.md 引入 iterations** — 模板含 `## 迭代历史` 章节，引用 `docs/iterations/`
7. **TG_USERNAME 自动检测** — TG/OpenClaw 触发时从 `OPENCLAW_TRIGGER_USER` 环境变量自动获取
8. **TG 通知命令** — `openclaw message send --channel telegram --target "$TG_USERNAME" --message "$MSG"`
9. **循环上限** — 每个 Gate/Test ≤ `$REVIEW_MAX_ROUNDS`（默认 3），超限通知人工+中止
10. **.env 完整注释** — 所有参数含类型、枚举值、默认值、示例

## 已生成的文件清单（21 个）

```
sdlc-workflow/
├── SKILL.md                                    # 入口（≤500行）
├── references/
│   ├── pipeline-overview.md                    # 12 步 Pipeline 概览
│   ├── requirements-ingestion.md               # 步骤① 需求采集
│   ├── requirements-clarifier.md               # 步骤② 需求澄清
│   ├── design-generator.md                     # 步骤③ 设计生成
│   ├── task-generator.md                       # 步骤④ 任务分解
│   ├── design-reviewer.md                      # 步骤⑤ Gate 1 设计审查
│   ├── code-reviewer.md                        # 步骤⑧ Gate 2 代码审查
│   ├── test-generator.md                       # 步骤⑦ 测试用例生成
│   ├── test-pipeline.md                        # 步骤⑨ 测试执行
│   ├── docs-updater.md                         # 步骤⑩ 文档更新
│   ├── git-committer.md                        # 步骤⑪ Git 工作流
│   └── tg-notifier.md                          # 通知规范
├── templates/
│   ├── CLAUDE.md.tpl                           # 含迭代历史引用章节
│   ├── workflow-rules.md.tpl                   # 工作流规则
│   ├── ARCHITECTURE.md.tpl                     # 架构文档
│   ├── SECURITY.md.tpl                         # 安全文档
│   ├── CODING_GUIDELINES.md.tpl                # 编码规范
│   └── env.example.tpl                         # 完整注释+枚举值
├── scripts/
│   └── init-project.sh                         # 项目初始化脚本
├── README.md                                   # 安装使用说明
└── LICENSE
```

## 审查要点

Codex 请重点审查以下方面：

### 1. SKILL.md 质量
- [ ] Frontmatter 格式是否符合 skills.sh 规范（name/description/argument-hint/metadata.openclaw）
- [ ] Body 是否 ≤500 行
- [ ] 初始化检测逻辑是否完整（检测 .claude/CLAUDE.md + docs/ARCHITECTURE.md）
- [ ] TG_USERNAME 自动检测逻辑是否覆盖三种场景（OPENCLAW_TRIGGER_USER / .env / 缺失提示）
- [ ] Pipeline 12 步编排是否与 plan-7.md 一致
- [ ] 每步是否正确引用对应 references/ 文件

### 2. References 完整性
- [ ] 12 个 reference 文件是否都包含：输入/输出/详细行为/命令模板/错误处理/TG通知文案
- [ ] design-reviewer.md 和 code-reviewer.md 的 Codex CLI 调用格式是否正确
- [ ] 循环逻辑是否引用 `$REVIEW_MAX_ROUNDS` 而非硬编码 3
- [ ] test-generator.md 输出路径是否为 `tests/unit/` 和 `tests/e2e/`（非 specs/）
- [ ] requirements-ingestion.md 是否包含 slug/type 生成逻辑
- [ ] design-generator.md 是否引用历史 iterations 上下文

### 3. Templates 正确性
- [ ] CLAUDE.md.tpl 是否包含 `## 迭代历史` 章节和 `docs/iterations/` 引用
- [ ] workflow-rules.md.tpl 迭代目录格式是否为 `YYYY-MM-DD/<slug>-<type>/`
- [ ] env.example.tpl 是否所有参数都有完整注释、类型、枚举值、默认值、示例
- [ ] env.example.tpl 中 TG_USERNAME 是否说明了自动检测机制

### 4. scripts/init-project.sh
- [ ] 是否创建 tests/（unit/e2e/reports/），而非 specs/
- [ ] 是否使用 `copy_if_not_exists` 不覆盖已有文件
- [ ] 是否向 .gitignore 追加 .env
- [ ] 是否有 `set -euo pipefail`

### 5. 架构一致性
- [ ] 所有文件中 TG 通知命令是否统一为 `openclaw message send --channel telegram --target "$TG_USERNAME" --message "$MSG"`
- [ ] 所有 iterations 路径引用是否为 `docs/iterations/YYYY-MM-DD/<slug>-<type>/`（非旧版平坦结构）
- [ ] 所有测试路径是否为 `tests/`（非 specs/）
- [ ] Git 分支命名是否使用 `${GIT_BRANCH_PREFIX}<slug>-YYYY-MM-DD`

## 版本演进历史

| 版本 | 关键变更 |
|------|----------|
| v4 | 初始设计，项目级 11 个独立 Skills |
| v5 | 修复 10 个问题：加 git-committer、修 OpenClaw 语法、混合澄清、循环上限 |
| v5 修订 | 恢复双模型把关（用户要求不可移除 design-reviewer） |
| v5.1 | 重构为用户级元 Skill（1 SKILL.md + references/），支持 npx skills add |
| v6 | 完整设计文档整合 |
| v7（当前） | 合并 specs/tests → tests/；iterations 加 slug-type 命名；CLAUDE.md 引入 iterations；TG_USERNAME 自动检测；.env 完整注释+枚举 |

## 运行方式

```bash
# 审查所有文件
cd /Volumes/HS-SSD-1TB/works/work-piple-1/sdlc-workflow

# 对照设计文档
cat ../plan-7.md
```
