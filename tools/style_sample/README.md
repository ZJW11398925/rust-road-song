# 有限人物资产导出

`export_people.py`是MPFB API消费者，不是人体/绑定工具。依赖已安装Blender 3.5.1、[MPFB v2.0-a3](https://github.com/makehumancommunity/mpfb2/tree/v2.0-a3)源码的`src`目录和[MakeHuman CC0系统包](https://static.makehumancommunity.org/assets/assetpacks/makehuman_system_assets.html)。MPFB工具GPL3；系统图形资产CC0。新版MPFB要求较新Blender，本轮没有升级或改动用户Blender配置。

命令（在仓库根，依赖解包位置作为参数）：

```powershell
blender --background --factory-startup --python tools/style_sample/export_people.py -- --mpfb-src .local/mpfb-a3-source/makehumancommunity-mpfb2-077d44f/src --assets-root .local/mh-assets --output-root .local/people-build-04
```

读取系统包中female_casualsuit02、male_worksuit01、shoes01、ponytail01、short02、low-poly眼睛的MHCLO/OBJ与材料依赖；不下载可选社区衣物。眼睛不用可选brown材质，采用简单暗色。

输出每人一份打包纹理的可编辑`.blend`、一份嵌入纹理/骨骼的`.glb`，及实际Blender版本/参数/源网格统计`build.json`。两个可编辑源已留在本机`.local/people-build-04/`；依赖/临时工具状态不提交。源网格统计包括MPFB遮蔽辅助面，不能当GLB实际三角形数。

女性试件gender=0、age=0.65；成年试件gender=1、age=0.35；均muscle=0.35、weight=0.48，其余为核心默认参数，不确定正式人物身份。调用MPFB game_engine原绑定，使用其rest-pose bake下放上臂；Godot使用原POC碰撞/走动，再将既有四肢摆幅叠加到导入骨骼原始姿态。不是精制步行或接触动画。

复查入口：在`pocs/stylized_3d/visual_v0/project.godot`中运行`asset_sample.tscn`；原默认首见入口保留。定向检查可运行`godot --path pocs/stylized_3d/visual_v0 --script res://asset_sample_smoke.gd -- --capture-dir=<已有输出目录>`，非headless时保存真实渲染帧。实际外观仍需逐张看图，逻辑计数不能代替形变检查。
