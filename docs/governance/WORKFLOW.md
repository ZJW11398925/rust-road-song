# DMCP 项目工作流

## 首轮恢复

总控按[Owner接续要求](sources/2026-10-11-owner-controller-handoff.md)先遵循[CONTROLLER_TAKEOVER](CONTROLLER_TAKEOVER.md)：完整理解设计和原始决定，读回实时状态，给出有来源的理解/边界核对后再布置执行任务。交接摘要和READY不能替代这一顺序。

1. 读 AGENTS、Owner/产品/故事/当前剧情与 POC，再读 binding、CURRENT、HANDOFF、任务及来源原文。
2. 核 `git status --short --branch`、`git log -5 --oneline`，确认修改所有者。查实际工具版本，不能沿用聊天中的修订。
3. `node scripts/dmcp.mjs tools` 取得当前 native schema；`node scripts/dmcp.mjs read` 获取完整正式对象与独立运行 sidecar；`node scripts/check_context.mjs` 校验本阶段文档。
4. 逐项核 DECISION/contract、PLAN、TASK、FINDING 和 attestation。完整读取器保留 MCP 截断诊断，并以引擎完整性校验读面补足所有对象；不能仅依靠 status 索引或前 4000 字。
5. 按实时正式工具与合法准入判定范围。GAP-DMCP-001 已对本次受限文档 Discovery 实际恢复，见 CURRENT 的新评估/报告提交回执；不能复用它批准 POC 或其他写路径。工具广告、结构 READY、测试 PASS 均不能替代当前阶段准入。

## 四种记录

- 人类来源：Owner 原话/讨论、精确出处、已决/提案/假设及被替代决定。关键摘录不是全聊天原文，不能补造缺失事实。
- Git 项目文档：产品权威与导航，任务说明、报告、变更、证据、交接。
- DMCP canonical：通过正规工具登记 DECISION、契约、PLAN/TASK、REVIEW/FINDING/VALIDATION；以 workspace/ref/revision/basis 追踪。Markdown 不冒充这些对象。
- runtime sidecar：实际能力/证据观测，不是 canonical 裁决或新的 Owner 权限。不存在时明确为空。

## 正式写入纪律

先检实际 schema 和适用能力，取得最新 `observed_canonical_state_id`、`observed_schema_version`、`observed_design_revision`；工具需要时提供目标对象当前 revision。只通过本项目专用、固定 SERVICE、代码约束 workspace 的合法写入入口操作。当前仓库提供的 CLI **仅能读**，不冒充尚未接入的执行通道。

一次写入先保存来源文件/hash、完整请求与投递意图到新操作目录；不得复用旧目录。回执保存 payload、basis、refs、warnings/audit/error；随即读取正式状态核对是否达到预期。请求表单是提案，不能自行给 Owner 裁决。新增系统先填写[五项说明](../templates/FEATURE_NEED.md)，Legacy 重用走重新准入。

结果未知、超时、回执无法持久化时停止后续写入，读原操作、canonical 和 runtime 核对，不生成第二次同等写入。`DO_NOT_RETRY` 不可重试；先解决错误所指能力/依据，不更换 ID 绕过。

普通 Agent 不得自升 ORGANIZATION_AUTHORITY、裁定 FINDING、裁定视觉胜出或创建替代工作区。建库时的一次性 owner 宿主操作来自本轮明确建库指令，回执保留；它不是未来 Agent 权限。

## 评审与验证

RB-DISC-001 的 Discovery 交付已被 RD-007 采用，原报告保留。C0 已另获匹配的原型执行准入并运行；文档 Discovery 协议仍不能授权代码/进程路径。C0 已按 RD-009 接受探索阶段；C1-A 新任务独立准入，C1-B/Visual 另审。Owner 原话与新决定分开存证，普通 Agent 不能自行作组织裁决。游戏阶段用每条体验验收映射运行证据及独立人工试玩；截图只能辅助。

不把“实施反馈”伪称宿主已有的接口：本版本 native 仅广告 16 个工具，含 review/validation 面；广告存在不等于 HUMAN_RUBRIC、完整 profile 或某执行路径可消费。缺能力记缺口和依赖，不能用自写 YAML/伪造 PASS 补齐。

## 收尾

变更记录先 IN_PROGRESS，提交已验证实现取得哈希，再关闭确实完成的工作。Owner 验收、产品假设验证、任务执行准入各自单列，不混淆。每轮更新 CURRENT/HANDOFF，原始依据与未覆盖项随证据留存；提交包含任务号+CHG。未达到验收的 TASK 不能宣布 DONE；历史 RB-REVIEW-002 只关闭方向转录/文档同步/正式登记；C0 已由 RD-009 阶段接受并保留未知项；C1-A 未人工接受保持 VERIFYING，不冒称原生 TASK DONE 或整个 POC 完成。

Git 外 canonical 不由 Git 提交备份。迁机按 TOOLING 迁移完整工作区/descriptor/对象/审计/runtime 并校验身份，禁止靠旧截图或复制一份 state 文件重建。

## 2026-10-11 文档 Discovery 受限消费（历史）

只读 CLI 额外校验受审 Discovery policy SHA-256 并传给宿主；未知/缺失/漂移配置拒绝。写通道不进入该 CLI，模型仍不能自授 ORG。

本轮受信宿主固定 SERVICE，仅一次 design_readiness 和唯一报告路径；提交前在同一 native lease 下重核原生 Owner 操作、当前 CST/修订、PLAN/TASK、能力、三 facts/requirements、实际 READY sidecar 与政策摘要。入口、dist/全部 specification/包 exports 和薄客户端分别锁摘要；没有任意进程或调用方路径参数。这是可信 LOCAL_RUNTIME 的一次有限入口，不是抵抗恶意 OS 的通用沙箱。

评估与提交共用 receipts/2026-10-11-discovery-admission；未知结果先查该目录与实际状态，不能再调用同目录或自行换新操作。已提交报告不覆盖。报告版本见 report-submitted.json 的 SHA；公开 full-readback 是仅删两项本机路径的完整对象投影，原始文件摘要见 consumer-verification.json。

上述受限消费描述的是已交 Discovery 报告路径。当前 Owner 已采用交付并修订下一阶段，新 C0 决定/PLAN/TASK 已登记；当时未签原生 TASK DONE，也未取得 C0 代码准入；当前情况见下节。CLI 仍没有通用写入或 readiness 查询。本轮一次性 Owner 转录仅消费原话“认同”及七项/两条保护，不授予未来 Agent ORG 权限。

## C0 原型受限消费（已冻结历史）

原生 prototype_execution@1 与文档 Discovery 独立， Finding 路径继续有效。本次新 DEC@2/PROTOTYPE风险PLAN/TASK及真实Owner操作建立4 requirements/4 facts，实际返回READY；只选择六个C0工程文件和报告路径、三个必要能力及固定Godot参数配置。旧拒绝不重试，不伪造FINDING。

本机固定SERVICE消费者在共享native lease下校验当前CST/schema/design、Owner真实操作、policy、READY sidecar和新鲜事实；写路径/二进制/参数与运行文件摘要逐次记回执，不接收调用方任意路径或参数。引擎HEAD、273项运行摘要和薄客户端摘要均校验。此为可信LOCAL_RUNTIME有限入口，不是OS通用沙箱；交互窗口租约只涵盖启动，不宣称覆盖整个试玩会话。

结果与投递意图见 receipts/2026-10-11-c0-admission。已有正式READY不得盲重投；同范围代码修正重核同一依据，C0→C1仍需新的具体授权/任务/选择，不因相同能力类重写协议。CLI仅读不变。原始带宿主路径的回执在私有存储，公开投影和原始SHA分别说明；不以投影冒称原始字节。


## C1-A 原型受限消费（归档，仍VERIFYING）

RD-009 真实 Owner 转录创建新 DEC@2/PLAN@1/TASK@1，旧9对象/2runtime原样保留。沿同一个 prototype_execution@1，仅更换精确十路径、固定 Godot 项目/参数与当前依据；不修改上游协议。新 READY 与每次部署/运行回执存 receipts/2026-10-11-c1a-admission；四事实与原生 sidecar 在共享 lease 下逐次核对，旧 C0 READY 不可消费。普通 CLI 仍只读，可信本机入口不是 OS 沙箱；实际人工可读性另验。

## 当前 C1-B异常小轮受限消费

Owner明确本总控承担宿主职责，仅转录已采用的具体小轮，见2026-10-12来源。两次真实Owner操作和SERVICE新PLAN/TASK已完成；沿同一prototype_execution@1选择新十路径/固定Godot参数，独立READY四事实/要求。旧12canonical/3runtime保留，C1-A选择/READY归档。当前固定SERVICE消费者.local/c1b-consumer.mjs共享native lease重核basis/事实/READY/273项依赖，部署和运行各存意图及回执；没有通用写入CLI或上游新协议。新游戏体验人工另验，不接发动/驾驶。

## RD-012剩余首见POC（当前）

最新Owner阶段接受并继续指令已保存，替代RD-011后段未授权的有限范围；SERVICE选择的机械因果仍候选。新DEC@2/PLAN@1/TASK@1与独立READY四事实/要求见CURRENT。沿同一原型协议，当前消费者.local/departure-consumer.mjs，十精确新路径/固定Godot过程；旧三工程25文件冻结。普通执行SERVICE，不自授产品裁决；不反复要求小灰盒复述，阶段接受与具体假设未观测分列，新后段人工状态不借旧轮“可以”冒称通过。
