# 2026-10-10 外部 Reboot 审查反馈

来源：Owner 本轮转交的外部评审。以下为关键原话摘录及接续处理，不是完整聊天副本。外部建议不能自动写成新的 Owner CONFIRM；本轮无需改动 22 项最高决定。

原话摘录：
- “GAP-DMCP-001 必须在 DMCP 所属项目中解决，但绝对不要为了它继续扩张《锈路长歌》的治理层。”
- “先证明空间与交互范式，再证明美术。”
- “现在不要继续细写 S00–S15 的正式对白。”
- “先解决 GAP-DMCP-001，然后让执行 Agent 正式执行 RB-DISC-001。不要再给它额外大任务。”

建议覆盖：首单以短表识别旧假设/危险/处理，交 A/B/C 技术、资产、工量、风险、公平比较及 Owner 问题；Discovery 无游戏，Owner 审后 Greybox，空间与输入成立再 Visual；不以完整系统或大量顶层文档扩范围。不预先决定视觉路线，也不现在设计离家后整款游戏。

现场核对：正式快照仍 schema/design 5/5、CST-a608e176-7228-4ae9-88c0-1bb845c802c0，3 canonical、0 FINDING、0 runtime；未新调用 readiness。消费引擎 a7cd117 的真实构建模块对这些实际对象投影得到 0 requirement，resolvePolicyBundle 仍 READINESS_BASIS_INCOMPLETE；这是只读机制复现，非准入。

上游隔离候选 codex/discovery-admission-gap 已保存 ADR-024 PROPOSED 及复现，GAP 未关闭。所提文档 Discovery policy 用当前明确 Owner/contract/PLAN/TASK/范围/能力形成非空要求，并叠加原有 Finding 阻断；不开放空集，不造 Finding、不改消费镜像。该方向改变既有 FINDING-only 语义，等待 Owner 裁决及上游正式实施/核验后，才审查绑定与恢复新评估。

本库只把三门与对白时机作为待审细化写入已有文档；不建立 workaround/override/temp gate。未写 RB-DISC-001_REPORT，未执行首单或 POC，未迁移模块。新增来源和本轮导航并非新 canonical 决定或任务；没有正式写入。
