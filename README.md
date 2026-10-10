# 《锈路长歌》 / rust-road-song

**2026-10-10 产品级 Reboot。** 这是新的 canonical repository，拥有独立 Git 历史和 DMCP 工作区。旧实现名义上冻结为 rust-road-song-legacy，仅供参考，不构成新版本设计约束。

我们保留世界观种子与技术经验，重新决定这到底是什么游戏。内容产生顺序是：**人物处境 → 玩家自然产生的欲望 → 玩家行为 → 必要机制 → 页面、数据与代码。**

当前唯一首要里程碑是**玛丽第一次出现 POC**：进入地下车库 → 看见玛丽 → 接近并检查 → 发现异常 → 发动 → 开出车库。现在建立设计上下文与比较方案；没有正式游戏代码，没有获胜视觉路线，没有完成序章的承诺。

## 从这里进入

1. [项目宪法](AGENTS.md)：进入项目必须先读。
2. [所有者决定](docs/00_OWNER_DECISIONS.md)与[产品主张](docs/01_PRODUCT_THESIS.md)：最高设计依据。
3. [故事基础](docs/02_STORY_BIBLE.md)、[序章规范](docs/03_PROLOGUE_DESIGN.md)、[叙事语言](docs/04_NARRATIVE_LANGUAGE.md)。
4. [视觉方向](docs/05_VISUAL_DIRECTION.md)、[统一 POC 方案](docs/06_VISUAL_POC_PLAN.md)、[Legacy 重新准入](docs/07_LEGACY_REUSE_POLICY.md)。
5. [决定日志](docs/DECISION_LOG.md)、[DMCP 当前状态](docs/governance/CURRENT.md)、[DMCP 工作流](docs/governance/WORKFLOW.md)和[交接](docs/governance/HANDOFF.md)。
6. [首张执行工单](docs/tasks/RB-DISC-001.md)：只审计、只给方案，交付后等 Owner 审查。

## 权威顺序

Owner Decision（等级 0）→ Product Thesis / Story Bible（1）→ 当前剧情设计（2）→ 当前 POC / Milestone（3）→ 技术实现（4）→ Legacy（最低，只参考）。DMCP 记录状态、依据和责任，不能代替 Owner 选择产品方向。

本库暂不建立 inventory、equipment、bounty_system、shop、crew_jobs、skill_tree、world_state 及对应完整系统。Godot 工程和三个实验目录在方案获审查批准后按实际需要出现；目录空壳不代表工作完成。

## 恢复工作

先读治理绑定及工作流，再执行 `node scripts/dmcp.mjs read` 取得实时完整正式对象与独立运行记录；执行 `node scripts/check_context.mjs` 校验文档链接与范围。首次换机按 [本机工具配置说明](docs/governance/TOOLING.md)配置 DMCP。本机路径不进入项目规则或游戏资源；DMCP canonical 工作区在 Git 外，备份它不能只靠 Git。

本轮仅本地建库，不创建远程、推送、发布或生成 AI 美术。Legacy 历史边界见[Legacy 定位](references/LEGACY.md)。

