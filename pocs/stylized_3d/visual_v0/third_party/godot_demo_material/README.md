# Godot官方静态材质资源

直接来源：[godotengine/godot-demo-projects](https://github.com/godotengine/godot-demo-projects/blob/52e30044658448149b04e8f69b475eebbfbd8f6e/3d/procedural_materials/materials/marble.tres)，稳定分支4.3，提交52e30044658448149b04e8f69b475eebbfbd8f6e，2026-10-13引入，MIT（完整LICENSE.md随附）。

old_paint.tres直接沿用官方Gradient→FastNoiseLite→NoiseTexture2D→StandardMaterial3D资源链。移除上游UID，颜色改为低对比旧灰绿；固定seed13，噪声3层、256²纹理，关闭原大理石的高光/rim，改金属与粗糙度、开启三向投影。未复制demo脚本、UI、shader或图片，无新纹理生成算法。纹理由引擎异步生成，生成结果不提交。

这只给V0旧漆大区少量变化，不表示真实磨损来源、正式贴图规格或V1资产管线已经成立。
