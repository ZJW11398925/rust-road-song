# RB-C1A-001_REPORT：First Meeting

状态：**VERIFYING，Owner 首轮读为“抚摸一个老朋友”，但区域镜头被指出不足；局部镜头修订已验证，修后体验待接受**。依据 [RD-009 / Owner“认同”](../governance/sources/2026-10-11-owner-c0-close-c1a.md) 与 [任务](../tasks/RB-C1A-001.md)。C0 探索阶段接受并冻结，四项缺失主观评价保留；本轮不补造、不选最终3D、不进入C1-B。

## 当前交付

[工程入口](../../pocs/stylized_3d/c1a/project.godot) → first_meeting.tscn；[操作说明](../../pocs/stylized_3d/c1a/README.md)。Godot 4.7.1.stable.official.a13da4feb、Windows/键盘、Compatibility；仅当前POC。

九个工程文件：静态门/灰盒车库、独立Mary与最低人形场景、局部阶段与人形脚本、集中候选文本、真实输入探针、README。C0六工程文件原样保留；没有复制Legacy、升级garage.gd或引入通用管理器。母亲、玛丽从开场已在SceneTree；实体门上升显露，无魔法生成。首版为门前正面/车侧两个区域镜头；当前局部连续同框构图见本轮修订。

WASD自由移动，E开门/右侧尝试触碰，R重置，Esc退出。门不关闭，触碰后仍可走动/返回。母亲绕左侧、停、转身、搭扶一个占位侧板；玩家不看/先右侧/先触碰不会阻塞她。只有该细节及极少候选文字，台词/侧板不是新故事设定。无异常、发动、驾驶、下车、Profile UI、漂亮资产、音频/面捕/特写、完整序章。

## 真实运行与反例

- 首次import发现场景浮点省略前导零，Godot退出0但含ERROR，按失败处理；这是解析错误，不计有效RED。
- 有效移动RED：正式入口加载/落地/远处E等6项通过，真实W不推动人物1项失败，退出1无脚本错误；恢复水平移动后通过。
- 首次GREEN33项/2FAIL：母亲已到位/朝向正确，测试时手势未完成。按路径和速度核时序，改为从开门起12秒有界观察，没有改游戏动作或放宽接触阈值；实际11.45秒完成，手与侧板0.05946米。旧33/0仅时序复验，不冒称最终体验通过。
- 独立审查发现6米入口侧墙遮动作、就近E直接隔空成功及回返sticky断言。修前真实键路径站到x3.15，E错误成功；动作/首见射线均首先撞EntryLeft。针对性RED为3PASS/4FAIL，不是解析错误。
- 最小修复：首见镜头移正面、入口左右墙降至3米，门仍6米；E只发起0.8秒伸手，手到真实车壳右面≤0.14米才记成功，WASD仍响应。触不到/移开有反馈。回返必须启动新动作/实际触壳，不靠旧成功bool。
- 最终正式入口 **44行为检查/0FAIL**，退出0且无ERROR/脚本错误/崩溃。真实玩家手到壳约0.030米，回返约0.017米；四条指定入口视线clear。它们是技术诊断，不是情感KPI。

实际命令：正规固定消费者 deploy/import/smoke/capture/play，逐次重核同一新依据。Godot等效参数见工程README；每次实际参数摘要、输入文件SHA和进程结果保存在本轮回执。原始私有日志与公开投影SHA分别列于 [game-verification](../governance/receipts/2026-10-11-c1a-admission/game-verification.json)，不以投影冒称原字节。[移动RED](../governance/receipts/2026-10-11-c1a-admission/movement-red.log)、[审查RED](../governance/receipts/2026-10-11-c1a-admission/review-red.log)、[最终smoke](../governance/receipts/2026-10-11-c1a-admission/smoke.log)、[capture](../governance/receipts/2026-10-11-c1a-admission/capture.log)。

## 验收映射与未验证

| 当前问题 | 直接证据 | 仍未知 |
|---|---|---|
| 首见 | 初始镜头到车被实体门挡；渐开时仍可移动；真实渲染帧 | 玩家是否愿意停一下，不由射线/截图证明 |
| 母亲同场 | 最低人形走/停/转/搭手，11.45秒动作与约6厘米接触；指定帧可见 | Owner首轮读为“抚摸一个老朋友”；修订后的构图/任意站位仍须试玩 |
| 一件细节 | 普通侧板与动作，没有发光/计数/热点清单 | 自然注意/解释是否成立；候选短句不锁表现层 |
| 自由行动 | 真实左右侧输入、先触碰、忽略动作、走开/回返、伸手中移开；不强锁 | 任意站位遮挡、长期误操作/堵路和自由叙事节奏 |
| 错误与恢复 | 远处E、够不到/移开失败反馈、门不关闭、R清输入、失焦通知清held/恢复新键 | OS级失焦、窗口/分辨率变化、实时性能 |

L1/L2局部动作/输入/状态在同一真实SceneTree探针合并验证，没有迁旧测试框架；L3为上下文精确范围与只读边界5项，不是连通证明；L4从正式main到完整键盘路线/渲染，不是只加载。**首轮 L5 原话已记录**：Owner读为“抚摸一个老朋友”，同时反对区域自动切镜。C0局部手感不继承为C1人物戏；当前镜头修订未获新试玩接受，保持VERIFYING。

渲染同路有44行为项、1目录与273PNG写入项，共318/0；3281帧，1280×800@60FPS。原录像176761718字节，SHA-256 edbf682461ae9bb73808b8096dc575efb65f00a818a1b99531457380e1419df8，私有忽略，不入Git。使用本机AMD Radeon Graphics；离线Movie Maker不是实时FPS基准。总控查看指定初态/手势帧只确认占位动作可见，不冒称非实现者试玩或关系成立。

## 正式依据与独立复核

新DEC@2/PLAN@1/TASK@1、schema/design5/17，12canonical/0FINDING/3runtime。旧9对象和2runtime逐项原样；原生TASK无DONE生命周期，本地C0阶段关闭由真实Owner新DEC记录。新[READY投影](../governance/receipts/2026-10-11-c1a-admission/assessment-projection.json)为4requirements/4facts；[读回](../governance/receipts/2026-10-11-c1a-admission/readback-verification.json)单列。

沿原有prototype_execution@1，精确十路径和固定Godot配置，没有上游协议开发。受审SERVICE消费者共享native lease核当前basis/真实Owner操作/新鲜事实/READY sidecar/273运行文件；旧C0 READY不可消费，旧DO_NOT_RETRY未重试。交互lease只覆盖启动，可信LOCAL_RUNTIME不是OS沙箱；CLI仍只读。

[机制审核](../governance/receipts/2026-10-11-c1a-admission/basis-independent-review.json)与[游戏初审](../governance/receipts/2026-10-11-c1a-admission/game-review-initial.json)/[复审](../governance/receipts/2026-10-11-c1a-admission/game-review-final.json)分列。复审实现规格PASS/质量APPROVE，不代表L5。没有重新跑上游旧全套测试来冒充游戏证据。

下一步只记录C1-A实际试玩的自然复述/误解及必要局部修正。即便局部戏可读也不证明完整家庭情感；C1-B异常/信息变化/启动与驾驶待Owner另裁。当前投入为一轮小舞台、导入修正、时序核验、两项局部修复和渲染/独立复核，墙钟含并行/等待，不声称获批固定工时预算。


录像后只将 strings.tres 行尾规范为LF并更新说明/报告，文字与行为未改；最终提交字节已另跑正式入口44行为项/0FAIL。录像原输入摘要保留，不能冒称录像与最终资源逐字节相同。

## CHG-20261011-005：首轮反馈与镜头局部修订

[Owner原话](../governance/sources/2026-10-11-c1a-first-playtest.md)同时提供局部熟悉感和镜头反例。旧 player.z<2.5 触发往返两构图，没有消费母亲动作；真实路线走0.6米使镜头位移9.912米，门口静止时母亲走全程而镜头不动。最终修前RED50项/3FAIL，无脚本错误。

当前只有场景内连续构图：开门时逐渐转向母亲/玛丽同框，目标跟随母亲实际位置，留少量玩家画面空间；她停下后构图自然停住，不由玩家跨区来回切镜。动作、输入、碰撞、台词与资产均未改，不锁操作、不用字面母亲第一人称或通用管理器。

实际 node .local/c1a-consumer.mjs deploy/smoke/capture；沿同一4facts/requirements READY逐次重核。最终smoke **52项/0FAIL**、无ERROR；同路渲染 **52行为+1目录+388PNG=441项/0FAIL**，4661帧、1280×800@60。旧边界镜头位移约0.196米；这些是几何诊断，不是情感KPI。头与手在投影画面内，不落HUD；总控看了三张实际帧，母亲走/搭手可见，右侧玩家仍可能局部被车遮住。

验证自身的两次问题保留：首条边界路线先横走撞到门框墙，改为先穿门再绕侧；头手探针最初错用无窗口64×64表面，改为相机使用的1280×800可见视口。后者未改游戏行为；录像探针与最终smoke探针字节不同，真实摘要分别保留。[本轮证据](../governance/receipts/2026-10-11-c1a-camera/verification.json)记录原/公开日志、录像摘要与旧录像归档。

本轮独立复审分派两次均因429未执行，不继承前版APPROVE；修后人物/镜头舒适仍未人工接受。C0六文件/Discovery原报告/全部12正式对象与3runtime未变，没有上游修改或准入重投。C1-B/Visual仍未授权。

## 2026-10-11 新总控接续复审与试玩准备

[Owner接续来源](../governance/sources/2026-10-11-c1a-verification-continuation.md)。上节两次429属于镜头修订首轮，另一次新总控复审在中间阅读后最终429中断，原失败记录保留。本轮使用只含要求/代码范围的独立上下文完成 /root/camera_review_compact 只读复审：八个运行文件与已测摘要一致，指定差异、连续构图、世界方向输入和重置逻辑未发现新增可行动阻断；未运行Godot或做人类试玩，不继承旧APPROVE、不作情感/镜头舒适裁决。[复审摘要及范围](../governance/receipts/2026-10-11-c1a-resume-verification/independent-review.json)。

本轮实时读回仍schema/design5/17、12canonical/0Finding/3runtime，与前轮完整对象逐项相同。沿既有固定消费者在共享native lease内重新核事实/Owner操作/READY/精确路径与进程，实际smoke-1791726581010再次52项/0FAIL、退出0且无ERROR/脚本错误；八个运行文件未改，无准入重投/上游修改。[本轮证据](../governance/receipts/2026-10-11-c1a-resume-verification/verification.json)。没有再生成录像，也没有改游戏代码。

试玩窗口已按固定play配置启动。普通沙箱查询提权PID时误报“找不到”，总控因此重复启动；提权现场查询确认两个窗口实际正常响应，根因是进程观察权限差异，不是已证实的游戏退出。总控核对精确PID/命令/开始时间后正常关闭本轮重复PID66856；保留play-1791726724450/PID63388。观察时标题C1-A First Meeting (DEBUG)、响应正常，无日志ERROR；启动租约只覆盖启动，不保证整个试玩会话。旧PID30344已在提权观察中确认不存在。

发出开放问题时尚无修后反馈，随后收到下节真实反例；不将窗口准备或只读复审当接受。任意站位遮挡、动作全程可读性/镜头舒适、OS焦点、窗口变化、实时性能仍未完整验证。C1-A VERIFYING、CHG-004/005 IN_PROGRESS保持，C1-B/Visual不进入。

## CHG-20261011-006：第二轮反例与双侧修正

[Owner原话](../governance/sources/2026-10-11-c1a-second-playtest.md)明确指出右侧视角不可用、为何非去右侧无法理解、入口墙很大程度挡视野。前版52/0与只读复审均未排除这些真实反例。最小需要在[CHG-006](../changes/CHG-20261011-006.md)先行填写。

真实键输入复现：右侧躯干被Mary/Body遮挡；入口外侧横走被EntryRight/Mesh遮挡；左侧相同合理接近被FAR拒绝。有效RED60项/4FAIL，无解析/脚本错误；第四项是左侧未触碰导致后续离开状态断言失败。前一次59/3未包含入口墙路线，独立保留。探针新增渲染模型AABB视线，含没有独立碰撞的UpperBody，不再将投影在画面内等同未遮挡。

修正仅限当前场景：镜头提高、侧向位置随玩家连续变化并限制在侧墙内，共享实际人物/车关系焦点；左右车侧沿同一伸手动作，仍须手抵达实际车壳才完成，移开/够不到仍失败。FAR文字去掉右侧要求。入口灰盒两段前景墙从3米降至0.8米，Mesh与碰撞同步，玩家仍不能穿墙离场，门仍遮挡初始首见。建筑高度和构图比例只是本轮候选，不锁正式美术/空间。

中间修正的60/2与两次60/1保留：高镜头/侧向变化解决车体遮挡后，入口前景墙及HUD占位仍造成失败；再共享实际空间和降低前景墙，最终61/0、无ERROR。原52项保留。渲染/独立审查/新试玩结果各自单列于本轮证据，不继承旧版本APPROVE。不扩展C1-B、Visual、正式资产或Legacy。

独立只读审查在一次429中断后完成，未发现产品阻断，提出一项Minor：左侧离开原断言只检松键/旧触碰状态，不能证明位移。加强直退位移后产生真实61/1；同侧正在走来的母亲会与玩家实体相遇，不能将直线退路写成畅通。没有删除碰撞或移走母亲，改为真实A22避让再S55，实际横移1.1米、z移2.75米，两键清除；最终61/0。审查者只复核末段，确认Minor解决；不继承旧APPROVE，也不把绕行成功冒称任何路径畅通。

[本轮完整证据](../governance/receipts/2026-10-11-c1a-sides/verification.json)与[独立审查范围](../governance/receipts/2026-10-11-c1a-sides/independent-review.json)：最终正式smoke61/0；同字节八运行文件的真实渲染61行为+1目录+518PNG=580/0、6220帧、1280×800@60，录像341927610字节；无ERROR。前一次离开断言修正前的578/0/6195帧录像另存，不替代最终证据；首版与CHG005录像也保留。总控看过四张指定入口墙旁/双侧姿态帧，只确认这些位置可见，不证明母亲戏强调或镜头舒服。离线Movie Maker不是实时性能测试。

验收对应：开门/初始遮挡与控制沿原52项；自由双侧触碰用真实手至对应车壳距离与实际键路径；入口视野用模型AABB/躯干投影及真实帧；低墙边界用实际S键不能穿越；恢复用重置清双侧触碰状态；母亲动作仍独立有界完成。L1/L2状态/数据流、L3错误与范围、L4正式入口键盘全程/渲染有本轮证据；L5第二轮反例原样保留，**本次修后新的L5尚缺失**。人物互遮、全身/车轮侧板与过渡遮挡、构图舒适、OS焦点/窗口变化/实时性能未完整验证。

末轮完整DMCP read与入口逐项相同，12canonical/0Finding/3runtime、schema/design5/17；固定消费者逐次验证既有READY，未写正式对象、未重投/换scope/改policy或上游。C0六文件及Discovery原报告冻结。C1-A VERIFYING、CHG-004/005/006 IN_PROGRESS保持，下一项只做本候选真实试玩或同任务必要局部修正。
