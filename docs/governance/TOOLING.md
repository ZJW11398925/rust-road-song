# 工具及本机配置

建库实际使用 Node 24.18.0、Git、官方 DMCP native 引擎与既有薄客户端。没有游戏插件、外部网络服务、AI 美术生产、付费工具或 Legacy 游戏模块接入。

引擎版本、工具链基线与实际客户端文件 SHA-256 见 [binding.json](binding.json)。建库时引擎为 DMCP resolution basis，历史 commit `a7cd1171dd3496a0bfd8e0bf4ff2fe9febc6e7dc`；工具链来源 commit `678c4dc64ae61ad7d57c42e9a7ebbf16d0dfb3be`。当前读取器校验客户端文件 hashes 与引擎 HEAD；不是供应链审计，也不独立认证全部 dist 文件或 sidecar 证据。

## 本机 profile

`.local/dmcp-host.json` 已在本机配置且被 Git 忽略，字段：repositoryRoot（此新库）、engineRoot（官方引擎安装）、workspacesRoot（集中 canonical 根）、toolchainRoot（已核对薄客户端与完整读取器）、legacyRoot（只读历史定位）、engineCommit、toolchainCommit。

本机路径不成为产品设计约束。换机时保留该字段结构并填写当地路径，安装相同 Node/引擎/客户端版本；只复制 Git 不够，需迁移完整 DMCP workspace（包括外部 descriptor 注册、canonical、审计和 runtime）并以绑定 ID 读回。找不到相同身份时停止，不自行 design_create 一份新身份。

## 项目 CLI

在仓库根执行：

```powershell
node scripts/dmcp.mjs tools
node scripts/dmcp.mjs read
node scripts/check_context.mjs
node --test scripts/tests/scope.test.mjs
```

`get request.json` 可读取指定对象；请求 shape 为 `{"tool":"design_get","arguments":{"workspace_ref":{"workspace_id":"本项目真实ID"},"refs":[{"kind":"DECISION","id":"正式ID"}]}}`。使用前依据 tools/list 的实际 schema。只允许 design_status、design_get、finding_list；递归拒绝所有嵌套其他 workspace_id。没有写入、建库、组织裁决和准入查询入口。

当前桌面已有的 `mcp__dmcp__*` 标准 facade 固定绑定其他项目，不能拿它操作本库。未来接入必须另建专用 SERVICE 通道并逐个验证 discovery、读取、写入边界及真实执行旅程；禁止修改其他项目绑定来临时绕过。当前只读 CLI 已验证，不宣称桌面工具或模型旅程已接入。

## 建库时宿主缺口（历史）

GAP-DMCP-001：空 FINDING 项目无法生成非空 readiness gate bundle。依据绑定版本 `startup-components.ts::resolveHostGatePolicy` 与实际 DO_NOT_RETRY 回执。不能靠修改模板提供非 FINDING 门禁。本轮没有修改外部引擎；新项目正式阶段准入未成立。

future AI/3D/美术工具必须先列目的、版本、许可证/使用权、成本、数据输入范围与审核方式，经 Owner 决定后采用。当前不存在推荐或采购决定。

## 2026-10-11 当前绑定

消费原生修复/证据版本 d270067（源码受验 ca002be），公开 binding 锁 engineCommit/documentDiscoveryPolicySha256；私有 profile 增 readinessPolicyFile，不提交本机路径。只读入口验证缺失/漂移政策并拒绝，仍仅 read/tools/get。

政策与语义归上游，本库不设 override/temp gate。换机需获取同一原生候选与原生 policy artifact，核对摘要后配置；不要重新造 workspace/模型政策。当前尚未推送原生候选/本次游戏提交，远端克隆不足以重建这些本机依赖。

真实文档 Discovery 已评估并通过固定宿主提交报告；普通 Agent SERVICE 与 Owner 转录入口分离。没有桌面 facade 接入、完整 PHASE1/profile 验收、模型带游戏工具的旅程或游戏试玩。独立跨模型静态审查在上游存证，报告交付不继承其 POC 权限。
