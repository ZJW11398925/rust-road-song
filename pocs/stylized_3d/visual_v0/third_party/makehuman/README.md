# CC0 人物基础小样

下载/导出：2026-10-13。两份GLB来自MakeHuman核心资产及MPFB v2.0-a3（GitHub tag，源码归档根077d44f），由本机Blender 3.5.1导出。不是正式母亲/主角设计。

- [MPFB原仓库](https://github.com/makehumancommunity/mpfb2/tree/v2.0-a3)、[兼容版本说明](https://static.makehumancommunity.org/mpfb/releases/release_20a3.html)。工具源GPL3，不随Godot工程打包或安装。
- [MakeHuman系统资产包](https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html)、[许可说明](https://static.makehumancommunity.org/about/license.html)。核心图形资产CC0，包内MHCLO声明2020-09释出；[完整CC0](LICENSE-CC0.md)随本目录保留。
- `woman_sample.glb`：核心人体、female_casualsuit02、ponytail01、shoes01、low-poly眼睛。
- `adult_sample.glb`：核心人体、male_worksuit01、short02、shoes01、low-poly眼睛。
- 资产作者包括Data Collection AB、Joel Palmius、Jonas Hauquier；具体文件声明保留在原下载包。本轮使用系统资产，不使用社区资产的不同许可。

生成参数和修改见[可重复导出工具](../../../../../tools/style_sample/README.md)。使用MPFB原人体生成、衣物贴合、遮蔽、绑定、权重与rest-pose bake；只将上臂下放为站姿、身体/眼睛改为哑光简单材质。没有重写对应算法。GLB保留53骨骼和衣物UV/贴图；Godot通过内嵌未压缩贴图导入，不提交导入缓存或自动解出的重复PNG。

当前服装、发型和肤色仅为技术试件；默认蓝色现代服装不适合作为游戏正式人物。Godot小样降低高光/禁用法线噪声，仍不是手绘材质。没有表情/面捕/成品步行循环，四肢摆动沿当前POC动作作局部适配。
