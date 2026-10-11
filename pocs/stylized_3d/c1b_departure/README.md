# RB-C1B2-001 / 首见片段剩余链条

2026-10-12；SERVICE 最小灰盒候选，Godot + Windows + 键盘。依据[实施计划](../../../docs/plans/RB-C1B2-001_IMPLEMENTATION_PLAN.md)、[Owner继续来源](../../../docs/governance/sources/2026-10-12-owner-graybox-continue.md)和该任务独立 READY；不复用旧任务准入。Legacy NONE；旧 C0/C1-A/C1-B 和原 Discovery 报告冻结。

入口 `project.godot` → `departure.tscn`。WASD 步行；E 就近开门/双侧触碰；F 在左前踏步附近登车，坐稳后按住 F 启动，松开取消未完成启动；发动后 W/S 正倒车、A/D 有限转向；松键停止；R 全场重置；Esc 退出。门只打开。没有下车、维修小游戏或离家决定。

母亲开门后可自行做旧裂口动作，再沿左侧到接点。提前登车/尝试会让她立即转去协助，实际手与接点距离 ≤0.14m 才积累 1.2 秒启动。没有观察/触碰/对白门槛和首次必败。点火后她收手，沿实体车外路线去踏步，再可见地抬高/移入座位。真实未就座时有制动反馈，防止车先开走；就座即恢复驾驶，不等字幕。动作/机械接点/座位/踏步都是可撤回执行候选，不登记为玛丽结构真相。

车库出口在世界 z=4，玛丽前进方向 +Z；前方只扩到 z≈12.8 的支持地面，z=12.65 外墙阻止离开 floor。原 z=8.8 横墙在新场景迁到该外边界，保持 3m 高墙。整车含踏步实际外沿 x=-1.98、右侧底盘 x=1.81、长轴 ±2.7 的保守角点全部越过门框 z=4.2 后结束。墙仍自动淡化，不降低。车辆用 CharacterBody3D，竖直支持与水平 move_and_collide 分开，撞实体当帧清速度，不沿墙滑。这里只验证连续操作，不证明情绪/乐趣或视觉路线胜出。

## 文件来源和依赖闭包

Reboot 来源提交 `90982c0cec3ea88f763464d01d3ddc983b33ccb2`，下表源文件均位于 `pocs/stylized_3d/c1b_anomaly/`；当前源 SHA-256 紧随表后。C0 仅借鉴 `pocs/stylized_3d/c0/garage.gd` 中缓起步、有限转向和分离支持/水平碰撞算法经验；不复制旧 C0 场景、Profile 或框架。

| 新文件 | Reboot 最小来源 | 当前依赖与删改 |
|---|---|---|
| project.godot | project.godot | 入口改 departure.tscn；保留 Compatibility/1280×800/中文配置，无插件 |
| departure.tscn | anomaly.tscn | 引用本地 departure.gd、human.tscn、mary.tscn；只扩 floor/外侧壁/边界，z8.8横墙迁走；原门/灯光/HUD保留 |
| departure.gd | anomaly.gd 的局部门、双侧触碰、母亲旧边动作、镜头/透明逻辑 | 只引用本地 human.gd/strings.tres 和本场景节点；新增场景唯一所有者启动/登车/驾驶/母亲路线状态，无服务或全局注册表 |
| human.tscn | human.tscn | 原最低人形、胶囊实体、手标记原样；仅引用 human.gd 和内置几何/材质 |
| human.gd | human.gd | 原歩行/伸手保留；新增一个局部就座姿态，无骨架或动画框架 |
| mary.tscn | mary.tscn | 原局部车体/旧边/跨隙组织保留；根改 CharacterBody3D，新增灰盒踏步/接点/两个薄座垫，无外部资产 |
| strings.tres | strings.tres | 原一条过去信息保留；新增必要机械原因/操作反馈，文本全部集中于此 |
| departure_smoke.gd | anomaly_smoke.gd 的输入/帧推进/截图手法 | 新线路读取实际 main_scene；动作只发 InputEventKey；不移动 body、不调用登车/启动/驾驶方法；失焦通知单列逻辑探针 |
| README.md | 新写 | 本次来源/依赖/候选与运行说明 |
| docs/pocs/RB-C1B2-001_REPORT.md | 新写 | 本次状态/证据映射；没有继承旧 PASS 或人类接受 |

源字节 SHA-256：

```text
anomaly.gd 4baa6c539be64d8aeb86cd864920c47fbd0ada709a998bdbd910c0fec959c6bf
anomaly_smoke.gd c2269ca5346590596d0cdf9eea9694b4b96f29d262bc5b00923b049fbf319f9b
anomaly.tscn a04cfe0640616fa83f3ac1df517158c3f30392d3b166e720375f4636566f66c1
human.gd 909b1593346d4aca56fb42a8833d477b3df39ad684755e6c601da68f86239534
human.tscn d6b420572c78d81570ca3257eda9140c6e8a0c3efec6a7c98d83bf1ce352c6a0
mary.tscn 0d7d3caebb48e5aa65d87c93e0b8dd7b2177f907560cccf88c1f9379f250f082
project.godot 5108cc818c4f33655d5061285e6f0e722590a75559ae7e4c739138c152ebb672
strings.tres 0c6cd98e9cb582dbd22e26f400dc502c673d99436a705b199fefe4032b55332c
```

只使用 Godot 内置基础网格/材质，没有 AI 生成、美术生产、声音、网络、SDK、付费资产或第三方插件。运行资源闭包限上述八运行文件；README/报告不参与运行。回退为保留旧冻结工程，删除本轮未采用的新独立工程；无旧状态迁移。

## 真实输入验证线路

`departure_smoke.gd` 一条有限线路以 R 串接早到、晚到、碰撞与最终忽略触碰驶出：远 F/启动前不能驱动 → 实际步行/E 开门 → 早登车无接点反馈 → 母亲实手接触 → 持有/释放 F/逻辑失焦/R 从启动复位 → 实际双侧 E 触碰 → 晚到第一次启动 → 母亲收手/绕实体/登乘 → W/S 与松键 → 真实有限转弯撞门框停且不滑 → R 驾驶复位 → 不触碰第一次可靠启动/失焦恢复/整车驶出/R/Esc。截图参数 `--capture-dir=` 可得到 10 个阶段 PNG，含接触、启动、就座、转驾、撞门框和外空地。

RED 与 GREEN 只在 departure.gd 的 `engine_running = true` / `engine_running = false` 一行不同，其他七运行文件相同；报告等非运行元数据另行更新。测试应在第一次可靠启动断言产生有意义行为失败，解析仍合法。必须总控先 RED 导入/运行，再 GREEN 同线路导入/运行与实际渲染；所有 ERROR/脚本错误/崩溃均 FAIL。实施者未运行Godot；总控正式消费有效RED45/1→GREEN89/0，实际渲染115/0。八运行字节相同，日志/指定画面与限制见[本轮报告](../../../docs/pocs/RB-C1B2-001_REPORT.md)。踏步为Mesh，外沿比底盘碰撞体突出0.17m；保守驶出条件包括它，但不能声称全部视觉外沿具实体碰撞。

自动线路/PNG不代替全路线镜头评估或人类体验验收。失焦使用应用通知，是逻辑清输入探针，不能称实际 OS 切焦证据。局部登乘是最低占位动作；不裁定正式登车结构、人物资产或完整家庭情绪。
