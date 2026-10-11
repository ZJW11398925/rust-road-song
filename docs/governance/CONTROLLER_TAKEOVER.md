# 新总控接续入口 / 2026-10-11

依据：[Owner 总控接续要求](sources/2026-10-11-owner-controller-handoff.md)。本文件只导航，不能替代设计正文、Owner 原话或 DMCP 实时状态。当前主线 main；最新局部修订属于 RB-C1A-001 / CHG-20261011-007。开始前核最新 Git，而不是沿交接中的历史哈希盲续。

## 第一轮：理解设计，然后才布置任务

总控负责保护设计权和验证边界。**完整阅读以下原文之前，不派执行 Agent，不开工新功能，不直接安排 C1-B。** 不让工单、已有工程或治理结构替代产品理解。不得只读本交接、聊天摘要、CURRENT 或报告摘要。

阅读顺序：

1. README、AGENTS、docs/00_OWNER_DECISIONS.md（22项OD、RD-007/008/009、全部未决项）。
2. docs/01_PRODUCT_THESIS.md、02_STORY_BIBLE.md，理解产品承诺、人物处境与玛丽的身份。
3. docs/03_PROLOGUE_DESIGN.md、04_NARRATIVE_LANGUAGE.md；读完整16节拍和世界因果/自由操作规则，不能只看当前车库片段。
4. docs/05_VISUAL_DIRECTION.md、06_VISUAL_POC_PLAN.md、07_LEGACY_REUSE_POLICY.md、DECISION_LOG.md。
5. 本目录 binding.json、CURRENT.md、WORKFLOW.md、HANDOFF.md、TOOLING.md。
6. sources/2026-10-10-owner-reset.md、2026-10-11-owner-discovery-review.md、2026-10-11-owner-c0-execution.md、2026-10-11-owner-c0-close-c1a.md、2026-10-11-c0-first-playtest.md、2026-10-11-c1a-first-playtest.md：区分评审建议、Owner采用范围、真实试玩与未验证推论。其他来源按正文链接补读。
7. 完整 Discovery/C0/C1-A 报告、当前工单、CHG-004/005/006/007和各轮证据；读[第二轮真实试玩](sources/2026-10-11-c1a-second-playtest.md)、[自动透明要求](sources/2026-10-11-c1a-wall-transparency.md)与[资源恢复授权](sources/2026-10-11-c1a-resource-recovery.md)。C0与Discovery有冻结边界；不要回头把旧实现/方案当现行要求。
8. 按下面入口读取完整正式对象、当前工具schema、runtime与真实回执，再检查匹配的当前执行依据。原始 DMCP 正文不能仅依赖可能截断的 design_get/status 输出。

读完先给 Owner 一个有来源的简短理解核对：为什么重启；两项产品承诺怎样共存；家庭/玛丽/战争哪些已定与未定；可操作叙事为何不能锁顺序；当前实验能证明什么；当前授权到哪里；最新反例与下一项最小未知是什么。**这项核对先于执行任务分派**；不是要求新 Owner 再批准已有决定。

## 必须理解的设计主线

人物处境 → 玩家自然欲望 → 行为 → 必要机制 → 页面/数据/代码。我们重新决定游戏是什么，没有沿旧RPG添加序章或换3D。代码没有设计权，“旧版做过”“RPG应该有”“以后用得上”不准入。

产品并存两项承诺：重装机兵式“这是我的旅程”（玩家产生目标），去月球式“这件东西以后不会忘记”（少量人物/物件不断改变意义）。离家之后如何过渡到自由旅程仍未验证，**现在不设计整款游戏**。

故事：持续约一年的平叛战争与异常加速衰败，父亲征召，母子留下；母亲不愿让归来的父亲无家可回。来信要求不要等待、带玛丽离开，熟悉语气“玛丽大展身手的时代到了”。不补父亲死亡/战争真相。玛丽先是旧、长期家用修补过的车，不是神器；老损伤一年后有不可能变化，暗红组织仍是候选、不解释异常。

序章《离家》是生活在坏掉的家、来信、车库首见、检查、异常、启动、最后一夜、母亲作离开决定、玩家驾驶离家后显标题；16节拍是叙事方向，不是当前全部开发。重要物件/决定可极短演出；普通说话/观察保持可操作。作者期望的顺序不是硬锁理由，仅观察损伤不能改变发动机。家庭痕迹用位置、动作、物件表达，不做热点/任务清单或讲解长对白。

Garage POC不证明爱上玛丽/玛丽成为家/完整旅行欲望；完整情感需要前置关系。三路线公平审查不等于三条都开发：A像素保留，B无独立体验假设暂不实施，C分轮攻击风险，未胜出。当前Godot/Windows/键盘只为快速回答问题，不锁产品技术。AI不是艺术指导；本轮没有正式美术/AI资产生产。

## 当前真实位置

- Discovery已采用，原报告冻结；GAP-DMCP-001已上游修复，旧DO_NOT_RETRY未重试。不继续扩张游戏治理或重做上游。
- C0已由RD-009接受探索阶段，六工程文件冻结。空间无已发现致命问题，驾驶“重量”来自缓起步、有限转向、松键即停、撞墙不滑移；不是车辆模拟/产品参数。四项主观评价缺失仍保留，不能写五项全部客观通过。
- 当前只有C1-A：另建最低人形舞台，门逐渐显露、一件细节、母亲一个动作/停顿、自由绕车/触碰结束。无异常、发动、驾驶、下车、Profile切换、完整对白、正式资产或通用系统。
- 首轮Owner真实复述：“感觉在抚摸一个老朋友”；同时指出区域自动切镜价值低、缺母亲强调且怪。这个证据支持局部熟悉感，不是C1-A整体接受。
- CHG-005已删除player区域往返切镜，连续构图跟随母亲/玛丽同框并保留玩家空间；未改动作/台词/输入。真实RED50/3，最终smoke52/0，无ERROR；渲染52行为+1目录+388PNG=441/0、4661帧。探针混用无窗口表面64×64/可见视口1280×800的问题已修正，录像与最终探针字节差异单列。截图/射线不等于镜头舒服。
- 上述52/441归CHG-005历史。随后接续只读复审完成，但[第二轮真实试玩](sources/2026-10-11-c1a-second-playtest.md)指出右侧视角、强制右侧和入口墙遮挡。CHG-006复现RED60/4后最小修正连续侧向镜头、双侧真实触壳与匹配碰撞的低前景墙；最终61/0、渲染580/0，独立审查提出离开证据缺陷并复核解决，见[实际证据](receipts/2026-10-11-c1a-sides/verification.json)。直退与同侧母亲实体相遇61/1及早期429保留；绕行可离开不能证明所有路线畅通。
- 随后Owner明确要求墙自动透明、否定CHG-006低墙；RD-010 / CHG-007恢复原3米墙，仅对已有墙独立材质按当前遮挡自动淡化/恢复，实体边界保留。有效RED66/3→66/0、实际渲染585/0；首个capture内存分配崩溃保留FAIL，经Owner授权重启OneDrive释放资源后同字节复跑通过，见[最新证据](receipts/2026-10-11-c1a-walls/verification.json)。独立静态复审完成，无可行动缺陷，原429保留。
- 最新Owner回复[“暂时就这样吧”](sources/2026-10-11-c1a-provisional-feedback.md)：本轮暂时收束，保留自动透明候选，不主动追加修正或追问，等待下一步指示。已有本版回复但未回答各项L5体验评价，不补作完整接受；C1-A仍VERIFYING，CHG-004/005/006/007仍IN_PROGRESS。有限采样不证明八墙所有路径/全身/快速过渡/排序阴影叠层，母亲动作强调/镜头舒适、窗口/OS焦点/实时性能未知。资源恢复不证明永无代码/驱动问题。不能继承旧APPROVE或自动进入C1-B。
- C1-B、A/B实施、Visual及最终3D选择都未授权。Owner随后[要求开始下一步](sources/2026-10-11-owner-next-step.md)，本轮已完成[仅异常可读的小轮提案](../pocs/C1B_ANOMALY_PROPOSAL.md)供具体裁定，未实施；不要因泛称下一步、“老朋友”或“暂时就这样吧”自行进入异常/启动。当前C1-A仍VERIFYING，是否携带未知项进入下一小轮须Owner明确审查。

## DMCP与首轮只读动作

在本仓库根依次执行：

```powershell
Get-Location
git status --short --branch
git log -5 --oneline
node scripts/dmcp.mjs tools
node scripts/dmcp.mjs read
node scripts/check_context.mjs
```

真实工作区 ws-217bac29-7a08-437c-be5f-472693bf16ca；本轮核过schema/design5/17、12canonical/0Finding/3runtime。DEC-OPI-50e5092d-5afe-478d-b0d0-9a465c8d3605.2@2，PLAN-OPI-a5367870-5bca-4c0a-bb74-ea2abfc706f9.2@1，TASK-OPI-3bb2876f-89de-4e7b-bbf9-5ae9f2bada04.2@1。当前CST-d3a92a52-a4b8-4d37-affa-f7e1584a83c3；**这些是本轮核实快照，接手以实时读回为准**。

当前PROTOTYPE READY为RDY-OPI-05151b82-23d7-42d6-b603-5cb7ee0a615d.2，4requirements/4facts，仅C1-A十精确路径和固定Godot参数。结构READY、登记TASK、自动化PASS、原版Owner反馈各自不是新阶段授权。原生TASK无DONE接口，不伪造生命周期。

同机新对话复用现有.local/dmcp-host.json、canonical、固定消费者.local/c1a-consumer.mjs、工具链与引擎；**不要创建新workspace**。普通CLI只读，桌面mcp__dmcp固定另一个项目，不能借用。每次代码部署/运行必须在固定消费者共享native lease内重新核当前basis/真实Owner操作/facts/READY，不重投已投readiness。不得擅升ORG、修改policy绕过或编辑.design。未知结果先查原意图/回执，DO_NOT_RETRY不重试。

上游86a8fc1已本地提交未推送，Git之外canonical及.local依赖不随public克隆携带。当前同机已验证可读；若迁机须按TOOLING迁完整身份/descriptor/状态/审计/runtime/锁定工具，不能只靠克隆重新造状态。新总控若不在canonical仓库根，先停实现并纠正项目上下文，绝不能沿Legacy提示继续旧路线。

当前public工程：pocs/stylized_3d/c1a；最新运行回执在 receipts/2026-10-11-c1a-walls/verification.json及c1a-admission；sides/camera为CHG-006/005历史。原始日志/各版录像含失败保存在.local，它们不是L5。当前候选录像.local/c1a-input.avi；最新交互启动若有见walls/play-window.json，不假设进程仍在或窗口已人工接受。

## 分派与收尾纪律

完成有来源的理解与边界核对后，任务必须回答PLAYER NEED、实际体验、最小实现、为什么不能更少、Legacy依赖；仅领当前授权范围。默认不复用Legacy、不造CameraManager/Quest/EventBus/完整UI/车辆物理/存档等底座，不继续装备、赏金、经济、职业、营地、大地图或完整战斗。L1/L2、静态范围、正式入口/真实键路径、渲染、独立审查、非实现者体验各自单列；失败与未覆盖项保留。

所有文档/操作中文；未知修改不覆盖。Owner持续授权main完成当前验证后主动提交/推送并读回，无需再问推送。范围/视觉胜出/新阶段仍由Owner裁决。更新CURRENT/HANDOFF时只保当前问题和入口；详情在报告/真实来源/回执，避免再次将治理当主要产物。
