# RB-C1B-001 异常可读小轮：准入执行计划

> 执行者按任务逐项推进；若以后进入游戏实施，用subagent-driven-development或executing-plans的逐项验证方式。本计划仅覆盖当前准入工作，不派游戏实施Agent、不创建新游戏代码。中文和本仓库文档布局优先于技能默认模板。

**目标：** 把[已获Owner采用的具体小轮](../governance/sources/2026-10-11-owner-c1b-anomaly.md)变成新的真实执行依据；准入成立前完成可交付源请求，不冒称已有TASK/READY。

**组织方式：** 保持同一真实workspace。产品来源、Owner正式操作、SERVICE计划任务、受限原型消费者四层分开；不建立新服务架构、override或通用MCP facade。

**技术：** 既有DMCP prototype_execution@1、锁定引擎/工具链/Godot；不改变既有273项runtime清单。游戏工程的实现计划在本轮实际准入后依据最终选定对象/路径编制；当前准备不写游戏实现。

## 全局约束

- 只回答旧损伤/不可能变化的局部可读性；启动、驾驶、异常答案、正式美术与完整C1-B未批准。
- 一处部位、一段身体反应、最多一句候选短文本；不增加热点清单、发光指示、强制特写或长解说。
- 任一侧、先触碰、忽略部位、走开/返回/打断均允许；观察不会成为以后发动的前置条件。
- C1-A保持VERIFYING，遗留问题携带；C0六工程文件/Discovery原报告保持既有冻结边界。
- 普通Agent固定SERVICE。不能改环境变量把自己设为ORGANIZATION_AUTHORITY，也不能把源码可调用误当宿主已经供给身份。
- 仅使用`ws-217bac29-7a08-437c-be5f-472693bf16ca`，所有嵌套workspace引用一致；CLI仍只读，不调用其他项目桌面facade。
- 写前核实时schema/basis/object revision，先存原话/hash/完整请求与意图；写后保存实际回执并完整读回；未知结果先核原操作，不自动重投。
- 当前无实际新准入，禁止修改binding、替换C1-A policy或生成新READY。不得通过调整check_context代码范围假装已获准。

## 第一项：真实来源与可投递Owner请求

文件：本次Owner来源；`docs/governance/requests/2026-10-11-c1b-anomaly/owner-decision.json`与`owner-contract-claims.json`；CHG008。

接口：消费真实用户回复及当前工具广告；产出未投递的原生`decision_add`参数，以及新DEC创建后才可绑定的契约变更列表。契约列表本身不是完整可执行请求，不能填假DEC ID。

- [x] 保存“推送并继续”及其直接回复上下文，区分产品授权与身份供给。
- [x] 固定完整提案十路径与两条核心排除：发动/驾驶不在范围；候选表现不确认异常本质。
- [x] 按锁定原生strict contract面离线检查首个请求与未绑定契约数组；递归核所有workspace引用。两个schema结果valid=true/errors=[]，仅证明格式，不证明权限或READY。
- [x] 确认所有请求尚未投递，记录其hash、当前basis与准确宿主缺口；不给它们赋operation ID/结果。原生格式核验与限制见[准备证据](../governance/receipts/2026-10-11-c1b-preparation/admission-preparation.json)。

离线检查使用锁定engine导出的`loadStrictToolContracts`与`validateInput`，加载同版本specification；第一请求的格式结果应合法。契约以同workspace/准备时basis及源mutations构造仅内存中的schema样本检查，不含目标DEC/修订，不保存为可执行请求。当前Ajv模块不能从已查目录单独解析，故使用原生校验面，不安装额外库。递归guard遍历对象和数组，遇到workspace_id不同即失败。

## 第二项：宿主Owner转录（当前不可由本Agent执行）

消费第一项源包及受信宿主实际供给的Owner身份；产出真实DEC@2、创建/契约的成功原生操作证据与完整读回。

- [ ] 宿主必须提供实际合法Owner通道；当前`.local/register-c1a.mjs`自行设置ORG且绑定旧来源/已用目录，既不可重投也不充当新入口。
- [ ] 在同一workspace读当前design_status与schema，校对源hash与Owner采用范围。源包的expected仅是准备时快照，过期不得直接投。
- [ ] 保存唯一新意图后投`decision_add`。成功回执中的primary_ref是唯一新DEC来源，禁止猜ID。
- [ ] 从真实新DEC与当前basis构造`design_update_contract`：expected.object_revisions绑定该DEC@1；只提交源包中的实验约束，不把“玩家一定看懂/3D胜出”写CONFIRM。
- [ ] 保存实际回执，完整读回新DEC@2与两次操作证据；确认旧12canonical/3runtime逐项保留。

缺口依据：锁定引擎`currentDocumentOwnerEvidence`对创建与契约操作都核principal=ORGANIZATION_AUTHORITY；这由宿主供应，SERVICE声明或Owner文字摘要不能替代原生证据。当前没有已接入、固定本项目的受信Owner入口，本轮不尝试伪造或自建ORG身份。

## 第三项：SERVICE正式PLAN/TASK与精确原型选择

此项严格依赖真实新DEC@2，当前不投递。

- [ ] SERVICE `plan_build`：PROTOTYPE / RISK_SPIKE，仅问题“自由走动时，旧破损边缘与当前新增形态能否自然产生不可能变化疑问？”；exit为真实可读/不可读证据交Owner，不授权后段。
- [ ] SERVICE `task_build`绑定新PLAN、该DEC及其ACCEPTANCE facet；required_capabilities仅REPOSITORY_READ/REPOSITORY_WRITE/PROCESS_EXEC；十精确路径与禁止变更使用已采用提案列表，不指向C0/C1-A工程。
- [ ] 完整读回PLAN/TASK真实修订，核引用/路径/GOAL和验收，并保留旧对象。
- [ ] 由受信宿主在同一prototype_execution@1中生成新的精确选择：新DEC/PLAN/TASK与两条实际Owner操作、新项目根/固定Godot参数/允许路径；policy_id/version、resolver/enforcement不变。实际生成和审查后才更新binding/profile，旧C1-A选择与READY原样归档。
- [ ] 新任务独立`design_readiness`仅投一次；保存原始意图/结果/实际facts/requirements，完整runtime读回。不是READY就按准确错误处理，不复用旧评估/造FINDING/改变scope。

## 第四项：实际执行依据消费与后续游戏实施

- [ ] 实际READY必须绑定本次真实basis/四facts与四requirements、精确十路径、过程参数和二进制SHA；受限SERVICE消费者逐次共享native lease重核，不能把当前源包或已登记TASK当READY。
- [ ] 只有上述条件成立，才在`pocs/stylized_3d/c1b_anomaly/`创建游戏文件、编写最终实现/RED计划，并依提案逐项核L1–L5。
- [ ] 进入代码时保留当前输入/人物/遮挡的最小经验，逐文件列复用原因与依赖；C0不复制，C1-A不改，Legacy NONE。
- [ ] 验证阶段分别记录可运行性、真实输入/渲染、独立静态审查和非实现者开放复述。没有实际运行的层次写N/A，原因是未准入，不写PASS。

## 本轮交付与推进限制

本轮交付是源包、格式核验、原始Owner采用、已授权边界同步与准确宿主缺口，不是新游戏或准入。Owner无需重复确认同一产品范围；需要的是宿主实际接入。未解决前不启动第二项之后的写入/实现，也不扩建游戏治理服务来绕过它。推送网络失败独立记录，网络恢复后完成持续授权的main推送并核远端。
