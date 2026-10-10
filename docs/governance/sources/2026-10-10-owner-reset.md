# 2026-10-10 所有者重置指令来源

来源：本轮用户消息（项目所有者提供与外部评审的讨论结果，并明确要求理解需求、在本地新建仓库、使用 DMCP 标准并继续 DMCP 工作流）。
这是关键原话摘录与覆盖索引，不是完整外部聊天记录；未提供的外部讨论不假装已读取。摘录保持原意，执行性转录见 00_OWNER_DECISIONS；Agent 方案见各文件状态，不混为原话。
本来源文件定稿后 append-only；更正新建来源并关联，不抹掉历史。

## 直接要求

> 从现在开始，本项目要进行一次巨大的转折，下列是我与外部评审讨论的结果，请理解我的需求，在本地建立新的项目仓库，并且，本次建库使用DMCP的标准，后续将依据DMCP工作流继续开发：

> 保留世界观种子与部分技术经验，重新决定这到底是什么游戏。

> 你可以参考，但你不能继承它的设计权威。

> 代码需要证明自己仍然有存在价值。

> 人物处境 → 玩家自然产生的欲望 → 玩家需要执行的行为 → 行为需要的机制 → 最后才是页面、数据结构和代码。

> 玩家此刻到底在经历什么？

## 提供方案的覆盖索引

| 用户内容 | 正式文档 |
|---|---|
| Legacy冻结/tag/命名，新库独立、不立即复制 | OD-001..003；07_LEGACY_REUSE_POLICY；references/LEGACY |
| 仓库最小结构，禁用目录与六步可玩片段 | AGENTS；06_VISUAL_POC_PLAN |
| 每模块重新申请、Localization/测试可评估、Bounty/装备/World不迁 | 07_LEGACY_REUSE_POLICY |
| 0..4及Legacy权威等级 | README；AGENTS；00_OWNER_DECISIONS |
| 总纲1..3：重置/设计顺序/重装机兵与去月球 | 01_PRODUCT_THESIS |
| 总纲4..6：一年战争/家庭/信/玛丽/异常 | 02_STORY_BIBLE |
| 总纲7：序章16节拍 | 03_PROLOGUE_DESIGN |
| 总纲8..10：操作剧情/短演出/环境/对话 | 04_NARRATIVE_LANGUAGE |
| 总纲11：道路/玛丽/信/候选旧歌 | 02_STORY_BIBLE |
| 总纲12..15：三路线/可玩比较/约束3D/AI审核 | 05_VISUAL_DIRECTION；06_VISUAL_POC_PLAN |
| 总纲16..20：默认不复用/冻结/Agent行为/唯一POC/走偏警报 | AGENTS；07_LEGACY_REUSE_POLICY |
| 第一个执行任务只审计/技术方案/等Owner审查 | tasks/RB-DISC-001 |
| 五项需求门、默认不复用、设计先于代码的提交历史 | templates/FEATURE_NEED；建库记录 |
| 第一批核心文档落地 | README、AGENTS及docs/00..07、DECISION_LOG |

## 本轮边界

仅新建本地仓库与正式上下文、冻结旧路线、接入独立 DMCP。未授权挑选视觉胜出路线、实现 POC、完成序章或扩张完整 RPG。根目录位置、保留旧物理路径是 Agent 落实选择，不称作 Owner 原话。

