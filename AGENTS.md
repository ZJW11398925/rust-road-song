# 《锈路长歌》Reboot 项目宪法

版本：0.3；2026-10-11。作用于本仓库全部内容。进入项目必须先读本文件。
本仓库是产品级重置，不是旧版本加序章、换 3D 或继续系统建设。旧仓库及其 AGENTS、UI 标杆、编号、测试基线仅为 Legacy 参考。

## 1. 必读顺序与权威

1. README → docs/00_OWNER_DECISIONS.md。
2. docs/01_PRODUCT_THESIS.md → docs/02_STORY_BIBLE.md。
3. docs/03_PROLOGUE_DESIGN.md → docs/04_NARRATIVE_LANGUAGE.md。
4. docs/05_VISUAL_DIRECTION.md → docs/06_VISUAL_POC_PLAN.md → docs/07_LEGACY_REUSE_POLICY.md。
5. docs/DECISION_LOG.md → docs/governance/binding.json → CURRENT.md → WORKFLOW.md → HANDOFF.md（后三份同目录）。
6. 当前任务、相关来源、正式 DMCP 对象和实际回执；涉及工具/资产时再读 docs/governance/TOOLING.md。

权威等级：0 Owner Decision；1 Product Thesis / Story Bible；2 当前剧情；3 POC / Milestone；4 技术实现；Legacy 最低。数字高低不代表文件时间新旧。DMCP 是治理事实载体，不赋予 Agent 产品裁决权。冲突必须先定位和修正文档，不凭猜测实现。Owner 明确的新指令优先，保存来源并登记被替代决定。

## 2. 内容产生顺序

人物处境 → 玩家欲望 → 行为 → 必要机制 → 页面/数据/代码。
禁止因为“RPG 都有”“旧版已实现”“容易做”“增加内容/深度”“以后会用”“项目完整”开工。讨论出现这些理由时暂停，重新问玩家此刻经历什么。

## 3. 当前范围

唯一首要里程碑：玛丽第一次出现 POC。进入车库 → 首见 → 接近检查 → 发现异常 → 发动 → 驶出。
RB-DISC-001 Discovery 交付已获本轮 Owner 采用，原报告保留；下一阶段方案按 RD-007 修订。当前实施方向是 RB-C0-001 Spatial Spike，按 RD-008 收缩为单次进入驾驶、门只打开和最小驾驶响应比较；本轮已取得精确范围的原型 READY，实际样本与人工反馈处于 VERIFYING，见 CURRENT/报告。
A/B/C 均须公平审查；只有明确体验假设的路线才进入可玩实施。C 先试 C0；A 保留；B 暂不实施。C1/Visual 独立审查。不得一次实现序章 16 节拍。
Garage POC 只验证空间、表现与操作，不证明完整家庭情感。比例/细节数量只作诊断，不作内容 KPI。合理操作不能因剧情节拍硬锁；仅观察损伤不得解锁发动。

暂不创建 inventory/、equipment/、bounty_system/、shop/、crew_jobs/、skill_tree/、world_state/，也不通过其他目录名建立同等系统。完整战斗、多车、经济、派系、大地图均冻结。
不预建 service architecture、EventBus、QuestService、WorldService、存档底座或完整 UI 框架。每项机制只服务当前行为。

## 4. 开工前五项说明

任何新功能/机制/资产接入的任务或 PR，在开工前完整填写 docs/templates/FEATURE_NEED.md 五项。不能回答“缺少它会损害哪项当前玩家体验”就不实现。
Legacy 默认不复用；任何进入申请按 docs/07_LEGACY_REUSE_POLICY.md，经当前需求、依赖闭包、许可证/版本、验证与 Owner 决定后才可复制。

## 5. DMCP 工作纪律

- 先核 Git HEAD、工作树与修改所有者；来源不明的修改不覆盖。
- 按 WORKFLOW 读实时完整对象与运行记录，再读具体原文；聊天摘要/CURRENT 不是实时状态。
- 不创建替代工作区，不使用 C:/system 或示例工作区冒充本项目。绑定文件 ID 为唯一项目身份。
- 写前获取实时 schema/basis 和对象修订；先保存来源与投递意图，沿合法工具写入，立即保存回执并读回。
- 普通 Agent 固定 SERVICE，不能自授组织裁决能力；只转录真实 Owner 指令，不能把提案/假设写成 CONFIRM。
- 超时或未知结果先查原操作及正式状态，不自动重试；DO_NOT_RETRY 必须遵守。
- 禁止手改 .design、伪造 ID/回执、用 Markdown 任务冒充 TASK、用结构 READY 冒充实施准入。
- 宿主缺能力时记录准确缺口；推进不依赖它的授权工作，不能换 scope 或削弱验收凑 READY。
- 每轮更新 CURRENT 和 HANDOFF，新增讨论来源/检查点，保存未决问题与下一步。
- RD-007 / RD-008 已批准 C0 方向；报告专属 READY 不授权代码。登记 PLAN/TASK 不等于实施准入；本轮另有原型 READY，须核实际事实/修订/精确路径。缺口归上游，不在本库建 override/temp gate。

## 6. 实现与资产

当前 POC 已批准 Godot + Windows + 键盘，正式产品技术仍待审；采用 Godot 时使用静态类型 GDScript，静态定义与运行时状态分离，永久引用采用稳定 ID，状态有唯一所有者。当前不建立为未来准备的抽象。
本机配置留 .local/，不提交密钥、绝对环境路径、导入缓存或生成文件。用户文本集中在可本地化内容中。
不引入游戏插件、网络服务、遥测、外部 SDK 或付费资产，除非 Owner 决定并登记版本与许可证。
同类交互在 POC 中先建立符合剧情的标杆，再复用；旧 TownServicePanel 不是新项目交互权威。

AI 可辅助概念/多视图、基础网格、动作镜头预演和一致性审核。资产必须按比例、造型、材质、配色、年代、磨损、腐败、技术规格统一审核，保存工具/输入/日期/使用权/人工调整。漂亮不构成正式准入。

## 7. 验证与收尾

文档建库验证：决定覆盖、候选/事实边界、链接、禁用系统、独立 Git 与 DMCP 身份、完整读回、错误路径；不声称游戏验收。
出现游戏代码后，按任务映射 L1 逻辑、L2 数据流、L3 已知失败静态探针、L4 正式入口真实生命周期/输入全程、L5 非实现者人工试玩。无代码层次写 N/A及原因，不写 PASS。
ERROR/脚本错误/崩溃即失败，退出码 0 无效；交互失败需玩家可见反馈；每条验收直接映射证据。静态截图不能裁决路线，自动冒烟不能证明情绪/乐趣。
变更记录先 IN_PROGRESS，提交实现、取得真实哈希，再记录已完成的部分；产品假设、任务提案、实施准入、实现、独立核验和 Owner 验收分别报告。未完成验收不能 DONE。
文档/记录中文，文件名与程序标识英文。提交包含本地任务与 CHG ID，禁止美化旧证据。Owner 2026-10-11 明确要求主线工作完成后主动推送：本库 main 的已授权变更完成验证与关闭后应推送并核对远端，无须逐次请求推送许可。

## 8. 开场动作

先完成必读与 `git status --short --branch`，运行 `node scripts/dmcp.mjs read` 与 `node scripts/check_context.mjs`。取得实时依据后读 RD-007 / RD-008 与 RB-C0-001；核对新的代码执行准入，不能继续按原报告下一阶段方案开工。不得从 Legacy HANDOFF 继续 176..179。
