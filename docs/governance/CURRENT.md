# 当前V0 / 2026-10-13

最新[Owner工作规则](sources/2026-10-13-owner-open-source-first.md)：新建设优先直接引入适合的成熟开源代码，只补缺口；小修只验证相关行为，不重复哈希遍历或另起治理轮次。此规则优先于历史交接中的通用重复要求，游戏产品范围不因此扩大。

最新[Owner负面反馈及转向诊断](sources/2026-10-13-owner-v0-negative-feedback.md)：战车造型距离目标太远；源码/旋转代数确认驾驶前进A/D车辆自身方向相反，旧碰撞断言没有覆盖转向符号。已按Owner“马上修复”取新纠错准入，运行仅转向符号修复；实际97/8→97/0、最终渲染109/0，前进/倒车四组方向角和位移均核验。首次渲染切焦109/1保留，不修饰为PASS。造型仍不成立，不进入V1/V2。此反馈优先于下文交付时点的未评价状态。

总控已完整理解设计/Owner原始决定/真实试玩，再读取正式对象与运行记录；交接不能代替设计正文。

Owner[“可以”](sources/2026-10-13-owner-visual-v0.md)采用RD-013：先V0视觉语言，V1/V2留候选。当前RB-V0-001 / CHG-20261013-012，只独立当前场景副本的形/面/色/光/密度、一页候选主张、3—5真实游戏帧及实际走动/继承输入回归。母亲回应信提醒并习惯性帮助，未决定离家；接点/座位/履带/按键仍占位，不精修成正式结构。具体视觉参数由SERVICE试验，不称Owner选定。

五项需求与验证见[计划](../plans/RB-V0-001_PLAN.md)、[一页候选](../pocs/VISUAL_THESIS_V0.md)，原[完整首见提案](../pocs/VISUAL_FIRST_SAMPLE_PROPOSAL.md)保留历史但未原样采用。无需重复小灰盒复述，L5未知不补PASS；A保留、B缺假设，C未胜出；AI/正式资产、V1/V2、整段样片、全序章另审。

实时schema/design5/29，21canonical/0Finding/6runtime，CST-cf07cf6b-16f1-4b06-89b1-79092167b080。新DEC-OPI-a2cced96-4eb7-4530-b8c5-7d121a27fbcb.2@2、PLAN-OPI-10ca7c03-19f0-40e0-992d-1c632dcac151.2@1、TASK-OPI-292e011d-3536-40ce-ab9f-565712661dc4.2@1；RDY-OPI-89f8a63f-7db3-4137-8228-127e3ffc0033.2实际READY。四NON_WAIVABLE事实/要求，十路径/固定Godot配置见binding及[新准入](receipts/2026-10-13-visual-v0-admission/assessment-projection.json)；旧18对象/5运行原样保留，见[读回核验](receipts/2026-10-13-visual-v0-direction/readback-verification.json)。native TASK无DONE接口。

当前新工程visual_v0；固定.local/v0-consumer.mjs每次共享native lease核实时依据、事实/READY/精确路径/工具运行摘要。CLI只read/tools/get；桌面DMCP固定其他项目不能用。总控[就是宿主](sources/2026-10-12-owner-host-clarification.md)，普通执行SERVICE，组织身份只转录真实Owner指令。未知结果先查原操作，不重投DO_NOT_RETRY，不改.design或建替代workspace。

旧四工程与Discovery34文件冻结。C0阶段接受仍保留四主观未知；C1-A仍VERIFYING。[老朋友原话](sources/2026-10-11-c1a-first-playtest.md)是关系提问下的局部正向反馈，伴镜头反例，不算无提示发现；[第二轮遮挡](sources/2026-10-11-c1a-second-playtest.md)、[高墙自动透明](sources/2026-10-11-c1a-wall-transparency.md)、[暂时收束](sources/2026-10-11-c1a-provisional-feedback.md)不补全L5。历史资源崩溃及Owner授权恢复保留，不证明长期资源。

异常小轮见[报告](../pocs/RB-C1B-001_REPORT.md)：37/7→37/0、渲染51/0，共面条纹FAIL与修后样本保留；阶段接受不证明自然异常可读。后段[报告](../pocs/RB-C1B2-001_REPORT.md)：45/1→89/0、渲染115/0/10PNG；真实R位置推移89/1及两种失败假设保留，一帧物理同步解决；HUD遮腿/踏步0.17m碰撞差异和smoke标签限制已列。后段人工仍未知，旧报告原字节冻结。

main持续授权完成验证后主动提交/推送并独立核远端。上一发布f6c10a918b75055af06fcab59736ba8241a26eaa。当前V0基线与最终正式入口输入89/0；最终实际渲染101/0、3445物理/3447录像帧、五独立PNG，八运行与旧34冻结SHA核验通过。任务代码/范围Approved；全轮0Critical/0Important/1Minor旧时态已纠正。限定技术实现提交cc7981db60bfe4b366a35fc6de9eb39646d26ac1已完成，发布以[真实记录](receipts/2026-10-13-visual-v0-verification/publication.json)核对。一次渲染55/16未重现，原因UNKNOWN；右侧仍暗、积木感/金属层次不足，均保留VERIFYING，不称视觉语言/稳定性/L5通过。最终证据写[本轮报告](../pocs/RB-V0-001_REPORT.md)。

当前纠错RB-V0-FIX-001 / CHG-20261013-013；DEC DEC-OPI-441c9dbc-2dd8-4ae1-a866-486bac55fca3.2@2，PLAN PLAN-OPI-66a14447-a331-4105-b3a5-b7cc0bae9036.2@1，TASK TASK-OPI-463747d5-f38f-4f10-9534-35c42b674d92.2@1，独立READY RDY-OPI-ee70e78f-9287-4ad2-b072-cc1bf7ac9b56.2；24对象/7运行，schema/design5/33。旧V0选择已归档binding.archivedV0Prototype；当前.local/steer-consumer.mjs固定十路径与原过程。这里只修左右，不扩大治理或美术范围。

纠错实现提交c825e653aa4e9df5bbc62befefa058b5eb370a65，限定技术核验完成；实际推送/远端读回由宿主保存，不据此接受视觉。
