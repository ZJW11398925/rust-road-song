# Reboot 建库交接 / 2026-10-10

## 接手结论

新 canonical repository 已本地建立，main，独立 Git 和 DMCP 身份；本轮只创建正式产品上下文和首单，尚未实施游戏或完成首单技术报告。Legacy 被产品指令冻结，176..179 不再接续。视觉/引擎/异常真相等候选未决。

## 权威与定位

先读 [AGENTS](../../AGENTS.md)，再 Owner/Product/Story/Prologue/Narrative/Visual/POC/Legacy。Owner 等级 0，技术等级 4，Legacy 最低。任务是 [RB-DISC-001](../tasks/RB-DISC-001.md)，只审计与三方案，交付后等 Owner。不能把旧 UI 标杆、服务结构、测试量带成新设计权威。

本机 profile `.local/dmcp-host.json` 保存新库与 Legacy 实际路径。Legacy 逻辑名 rust-road-song-legacy；物理根与远程尚未改名，以免破坏已有 worktree 与未获请求的远程动作。历史 commit 与 tag 见 [定位](../../references/LEGACY.md)和 [冻结清单](../../references/LEGACY_FREEZE.json)。本库没有远程。

## 正式状态与阻断

读取 [binding](binding.json)与[CURRENT](CURRENT.md)，所有 ID/原始回执均有链接。建库完整读回 schema/design revision 为 5/5，3 个对象，0 FINDING、0运行 attestation；该读回是历史检查点。

首单执行准入查询失败：READINESS_BASIS_INCOMPLETE、INTERNAL、DO_NOT_RETRY。宿主 FINDING-only 的空门禁能力缺口 GAP-DMCP-001 阻断正式写入，不能造 FINDING 换 READY；结构 READY 只说明对象一致。当前只读 CLI 可用，标准桌面 facade/真实模型旅程未接入。

## Git 与文件所有者

首三提交 71c9b9d、e850829、02fe830；建库实现与关闭哈希记在 [CHG-20261010-001](../changes/CHG-20261010-001.md)。关闭记录提交为当前 HEAD，可用 `git log -5 --oneline` 精确读取，不预编哈希。

建库实现提交 b367a2de018dcda22d0433c66969a80b5b927858；本关闭记录即 HEAD。关闭提交的变更只有 CHG/CURRENT/HANDOFF/BOOTSTRAP_PLAN，均属建库 Agent，并纳入该关闭提交；不留游戏或外部来源的未提交修改。现场最终 Git 检查见交付说明。忽略的 `.local/` 由本机宿主管理，不是未提交的游戏修改。新会话必须重新检查 git status，历史“干净”不能替代现场。

## 验证及未覆盖

已运行只读边界测试、项目上下文检查、native tools/list、实时全对象/sidecar 双读核对与来源 hash；详情见 CHG 与回执。无 Godot 工程，游戏 L1–L5 均 N/A，未进行游戏输入/视觉/情绪试玩。准入失败原样记录，未伪写 PASS。

## 第一轮可执行动作

```powershell
git status --short --branch
git log -5 --oneline
node scripts/dmcp.mjs read
node scripts/check_context.mjs
```

随后读本轮来源、Owner DECISION contract、PLAN/TASK、准入投递和拒绝原文。先处理宿主依赖 GAP-DMCP-001，在其所属项目依流程修复、验证并审查更新绑定；本项目不在背后改外部依赖。合法准入成立后完成 RB-DISC-001 技术报告。任何时候都不能自行开始游戏、导入旧模块或宣布视觉胜出。
