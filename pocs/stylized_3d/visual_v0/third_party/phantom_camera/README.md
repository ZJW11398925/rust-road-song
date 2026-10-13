# Phantom Camera阻尼与Framed摘录

来源：[ramokz/phantom-camera](https://github.com/ramokz/phantom-camera)，v0.11.0.3，提交cb6e0966ac305202c47f1d1a81c105966e29da96，2026-10-13引入。原许可MIT，Copyright (c) 2022 Marcus Skov，完整LICENSE随附。

摘录原文件addons/phantom_camera/scripts/phantom_camera/phantom_camera_3d.gd的_smooth_damp函数。公式、速度更新和防过冲原样复用；调整缩进，将INF速度限制换为maximum_speed，并添加RefCounted/Vector3薄适配及零delta保护。两个实例只服务V0相机位置和焦点，不是完整插件，也不承担取景设计。

RB-V0-FIX-005另引入framed_follow.gd：摘录同版本FollowMode.FRAMED的屏幕坐标归一化、_get_framed_side_offset边界比较、未越界轴锁定与偏移记录。边界公式直接复用；省略编辑器、Host/激活与零尺寸模式，显式传入Camera3D、目标与避开HUD的可用矩形。场景适配以现有双侧候选机位提供follow offset，并在车侧朝向不可见/射线遮挡时允许横向跟进；未越界轴保留已触发的目标以完成过渡。水平/垂直容许宽高0.44/0.50。并非完整插件或原样复用上游所有调度，具体取景与适配责任仍在本项目。

官方[Framed说明](https://phantom-camera.dev/follow-modes/framed)与[固定版本源码](https://github.com/ramokz/phantom-camera/blob/cb6e0966ac305202c47f1d1a81c105966e29da96/addons/phantom_camera/scripts/phantom_camera/phantom_camera_3d.gd)。上游提示Look At与Follow组合未完全测试；本轮不用其完整组合，实际验证边界见[记录](../../../../../docs/changes/CHG-20261013-018.md)。

母亲脚部离开HUD上方安全区时另允许纵向后退；安全区内保留已触发机位，不每步追踪母亲。这是本项目次要人物保护适配。步行阻尼每轴速度上限3.2m/s；行驶另在车的平移参考系中延续现有视角，未继承车身转角。这些取景参数/适配均不归称上游作者的设计。
