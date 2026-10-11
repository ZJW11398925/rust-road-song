# RB-C1A-001_REPORT：First Meeting

状态：**VERIFYING，最小可玩交付已运行，非实现者人物戏反馈待记录**。依据 [RD-009 / Owner“认同”](../governance/sources/2026-10-11-owner-c0-close-c1a.md) 与 [任务](../tasks/RB-C1A-001.md)。C0 探索阶段接受并冻结，四项缺失主观评价保留；本轮不补造、不选最终3D、不进入C1-B。

## 当前交付

[工程入口](../../pocs/stylized_3d/c1a/project.godot) → first_meeting.tscn；[操作说明](../../pocs/stylized_3d/c1a/README.md)。Godot 4.7.1.stable.official.a13da4feb、Windows/键盘、Compatibility；仅当前POC。

九个工程文件：静态门/灰盒车库、独立Mary与最低人形场景、局部阶段与人形脚本、集中候选文本、真实输入探针、README。C0六工程文件原样保留；没有复制Legacy、升级garage.gd或引入通用管理器。母亲、玛丽从开场已在SceneTree；实体门上升显露，无魔法生成。门前正面与车侧两个局部镜头构图。

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
| 母亲同场 | 最低人形走/停/转/搭手，11.45秒动作与约6厘米接触；指定帧可见 | 是多年熟悉、普通维修还是功能NPC，须开放复述 |
| 一件细节 | 普通侧板与动作，没有发光/计数/热点清单 | 自然注意/解释是否成立；候选短句不锁表现层 |
| 自由行动 | 真实左右侧输入、先触碰、忽略动作、走开/回返、伸手中移开；不强锁 | 任意站位遮挡、长期误操作/堵路和自由叙事节奏 |
| 错误与恢复 | 远处E、够不到/移开失败反馈、门不关闭、R清输入、失焦通知清held/恢复新键 | OS级失焦、窗口/分辨率变化、实时性能 |

L1/L2局部动作/输入/状态在同一真实SceneTree探针合并验证，没有迁旧测试框架；L3为上下文精确范围与只读边界5项，不是连通证明；L4从正式main到完整键盘路线/渲染，不是只加载。**L5尚无本轮新人工反馈**；C0的局部手感不能继承为C1人物戏通过。已开启实际试玩窗口并请求开放复述；保持VERIFYING。

渲染同路有44行为项、1目录与273PNG写入项，共318/0；3281帧，1280×800@60FPS。原录像176761718字节，SHA-256 edbf682461ae9bb73808b8096dc575efb65f00a818a1b99531457380e1419df8，私有忽略，不入Git。使用本机AMD Radeon Graphics；离线Movie Maker不是实时FPS基准。总控查看指定初态/手势帧只确认占位动作可见，不冒称非实现者试玩或关系成立。

## 正式依据与独立复核

新DEC@2/PLAN@1/TASK@1、schema/design5/17，12canonical/0FINDING/3runtime。旧9对象和2runtime逐项原样；原生TASK无DONE生命周期，本地C0阶段关闭由真实Owner新DEC记录。新[READY投影](../governance/receipts/2026-10-11-c1a-admission/assessment-projection.json)为4requirements/4facts；[读回](../governance/receipts/2026-10-11-c1a-admission/readback-verification.json)单列。

沿原有prototype_execution@1，精确十路径和固定Godot配置，没有上游协议开发。受审SERVICE消费者共享native lease核当前basis/真实Owner操作/新鲜事实/READY sidecar/273运行文件；旧C0 READY不可消费，旧DO_NOT_RETRY未重试。交互lease只覆盖启动，可信LOCAL_RUNTIME不是OS沙箱；CLI仍只读。

[机制审核](../governance/receipts/2026-10-11-c1a-admission/basis-independent-review.json)与[游戏初审](../governance/receipts/2026-10-11-c1a-admission/game-review-initial.json)/[复审](../governance/receipts/2026-10-11-c1a-admission/game-review-final.json)分列。复审实现规格PASS/质量APPROVE，不代表L5。没有重新跑上游旧全套测试来冒充游戏证据。

下一步只记录C1-A实际试玩的自然复述/误解及必要局部修正。即便局部戏可读也不证明完整家庭情感；C1-B异常/信息变化/启动与驾驶待Owner另裁。当前投入为一轮小舞台、导入修正、时序核验、两项局部修复和渲染/独立复核，墙钟含并行/等待，不声称获批固定工时预算。


录像后只将 strings.tres 行尾规范为LF并更新说明/报告，文字与行为未改；最终提交字节已另跑正式入口44行为项/0FAIL。录像原输入摘要保留，不能冒称录像与最终资源逐字节相同。
