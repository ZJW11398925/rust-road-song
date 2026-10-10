# DMCP 项目工作流

## 首轮恢复

1. 读 AGENTS、Owner/产品/故事/当前剧情与 POC，再读 binding、CURRENT、HANDOFF、任务及来源原文。
2. 核 `git status --short --branch`、`git log -5 --oneline`，确认修改所有者。查实际工具版本，不能沿用聊天中的修订。
3. `node scripts/dmcp.mjs tools` 取得当前 native schema；`node scripts/dmcp.mjs read` 获取完整正式对象与独立运行 sidecar；`node scripts/check_context.mjs` 校验本阶段文档。
4. 逐项核 DECISION/contract、PLAN、TASK、FINDING 和 attestation。完整读取器保留 MCP 截断诊断，并以引擎完整性校验读面补足所有对象；不能仅依靠 status 索引或前 4000 字。
5. 按实时正式工具与合法准入判定范围。当前 GAP-DMCP-001 尚未解决，停止正式执行写入；可只读理解。工具广告、结构 READY、测试 PASS 都不能替代阶段准入。

## 四种记录

- 人类来源：Owner 原话/讨论、精确出处、已决/提案/假设及被替代决定。关键摘录不是全聊天原文，不能补造缺失事实。
- Git 项目文档：产品权威与导航，任务说明、报告、变更、证据、交接。
- DMCP canonical：通过正规工具登记 DECISION、契约、PLAN/TASK、REVIEW/FINDING/VALIDATION；以 workspace/ref/revision/basis 追踪。Markdown 不冒充这些对象。
- runtime sidecar：实际能力/证据观测，不是 canonical 裁决或新的 Owner 权限。不存在时明确为空。

## 正式写入纪律（宿主准入恢复后）

先检实际 schema 和适用能力，取得最新 `observed_canonical_state_id`、`observed_schema_version`、`observed_design_revision`；工具需要时提供目标对象当前 revision。只通过本项目专用、固定 SERVICE、代码约束 workspace 的合法写入入口操作。当前仓库提供的 CLI **仅能读**，不冒充尚未接入的执行通道。

一次写入先保存来源文件/hash、完整请求与投递意图到新操作目录；不得复用旧目录。回执保存 payload、basis、refs、warnings/audit/error；随即读取正式状态核对是否达到预期。请求表单是提案，不能自行给 Owner 裁决。新增系统先填写[五项说明](../templates/FEATURE_NEED.md)，Legacy 重用走重新准入。

结果未知、超时、回执无法持久化时停止后续写入，读原操作、canonical 和 runtime 核对，不生成第二次同等写入。`DO_NOT_RETRY` 不可重试；先解决错误所指能力/依据，不更换 ID 绕过。

普通 Agent 不得自升 ORGANIZATION_AUTHORITY、裁定 FINDING、裁定视觉胜出或创建替代工作区。建库时的一次性 owner 宿主操作来自本轮明确建库指令，回执保留；它不是未来 Agent 权限。

## 评审与验证

RB-DISC-001 只交审计与三方案，不执行 POC。Owner 审查保留原话，合法登记后才能建立下阶段 PLAN/TASK。游戏阶段用每条体验验收映射运行证据及独立人工试玩；截图只能辅助。

不把“实施反馈”伪称宿主已有的接口：本版本 native 仅广告 16 个工具，含 review/validation 面；广告存在不等于 HUMAN_RUBRIC、完整 profile 或某执行路径可消费。缺能力记缺口和依赖，不能用自写 YAML/伪造 PASS 补齐。

## 收尾

变更记录先 IN_PROGRESS，提交已验证实现取得哈希，再关闭确实完成的工作。Owner 验收、产品假设验证、任务执行准入各自单列，不混淆。每轮更新 CURRENT/HANDOFF，原始依据与未覆盖项随证据留存；提交包含任务号+CHG。未达到验收的 TASK 不能宣布 DONE；本轮只关闭建库，不关闭 RB-DISC-001，也不宣布 POC 完成。

Git 外 canonical 不由 Git 提交备份。迁机按 TOOLING 迁移完整工作区/descriptor/对象/审计/runtime 并校验身份，禁止靠旧截图或复制一份 state 文件重建。
