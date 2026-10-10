# 本地 Reboot 建库计划

任务：RB-BOOT-001；变更：CHG-20261010-001；来源：2026-10-10-owner-reset。
状态：COMPLETED（仅建库）；实现 b367a2de018dcda22d0433c66969a80b5b927858，关闭记录即 HEAD；正式首单执行仍阻断。
Goal：建立可直接交给执行 Agent 的独立设计上下文和 DMCP 工作入口，不写游戏。
Architecture：独立 Git + 等级化中文文档 + 独立 DMCP canonical 身份。消费现有本机 DMCP 工具链，仓内只留薄入口与回执，不建立游戏框架。
工具：Git、Markdown、现有 Node/DMCP 原生运行时；不是游戏引擎裁决。

按顺序完成：
1. 核验旧现场、治理门禁、当前 HEAD/worktree；保存准确 Legacy 边界，不覆盖未知修改。
2. 建新本地独立目录，第一提交 README/Owner Decisions/Product Thesis。
3. 第二提交故事/序章/叙事；第三提交视觉/POC/复用/宪法/首张工单。
4. 获取 DMCP 实时 schema，通过受控 Owner 建库动作创建一次独立 workspace；逐步保存意图、结果与异常，不自动重试。
5. 登记已决重置与 CONFIRM/PROPOSE/ASSUME 的边界；登记实际 discovery PLAN/TASK，并保存实际 readiness。
6. 普通 SERVICE 只读入口固定绑定；完整状态读回、来源清单/哈希、交接；运行正常及跨项目/嵌套引用/写入/null拒绝验证。原拟写入入口因 GAP-DMCP-001 收束为未接入，不预建无法准入的执行通道；初始化 native 写入回执完整保留。
7. 自审决定覆盖、链接、范围、Git独立、DMCP身份；游戏 L1-L5 N/A，不声称可玩。
8. 先提交建库实现，再用真实提交号写收尾记录；Owner审查门仍关闭 POC编码。
9. 旧库只作冻结入口/标签与追踪记录；不修游戏、不宣称旧验收完成、不移动其他会话工作树。

异常：新目录已存在则不覆盖；create结果未知则查集中根及操作账；schema拒绝保留失败；准入拒绝保留真实码。任何问题不能用另建workspace或伪造对象绕过。

