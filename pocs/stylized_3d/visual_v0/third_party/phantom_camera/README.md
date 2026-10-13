# Phantom Camera阻尼摘录

来源：[ramokz/phantom-camera](https://github.com/ramokz/phantom-camera)，v0.11.0.3，提交cb6e0966ac305202c47f1d1a81c105966e29da96，2026-10-13引入。原许可MIT，Copyright (c) 2022 Marcus Skov，完整LICENSE随附。

摘录原文件addons/phantom_camera/scripts/phantom_camera/phantom_camera_3d.gd的_smooth_damp函数。公式、速度更新和防过冲原样复用；调整缩进，将INF速度限制换为maximum_speed，并添加RefCounted/Vector3薄适配及零delta保护。两个实例只服务V0相机位置和焦点，不是完整插件，也不承担取景设计。
