# 创游社资源入口筛选 / 2026-10-13

Owner提供[创游社工坊](https://chuangyoushe.games/#/workshop)，要求延续成熟资源复用方向。已通过实际网页读取工作台、素材目录和美术Skill详情；素材目录当时显示51个站点。以下是当前工作的筛选结果，不是已安装或已导入资产。

## 当前需求与取舍

当前需要参照成熟游戏确定整体风格，再制作环境与人物的风格验证。Owner在三款原游戏中更认可《极乐迪斯科》，见[真实偏好](../governance/sources/2026-10-13-owner-disco-preference.md)。停止独立玛丽造型；素材选择不能反向规定风格。

| 入口/具体资源 | 原站已核对的内容 | 当前可服务的工作 | 取舍 |
| --- | --- | --- | --- |
| [Poly Haven](https://polyhaven.com/license) | HDRI、贴图和模型资产CC0；网站文字、示例渲染等不随资产授CC0 | 环境照明测试、旧生活道具的基础模型 | 保留。其写实材质需要按参照概括色面，直接堆高频PBR不能得到绘画式外观；尚未选中单件资产 |
| [ambientCG](https://docs.ambientcg.com/license/) | 可下载资产和材质预览为CC0 | 墙、地面、木材/金属的材料底稿 | 保留。先选材料大面与色彩，再降低高频细节，不把纹理贴满当风格完成；尚未选中单张贴图 |
| [Quaternius Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) | 2025-08；6种男女基础体型及发型，humanoid绑定、glTF/FBX、CC0；有免费与付费Source层级 | 直接复用人物拓扑/绑定，避免从零重建基础人形 | 候选。优先评估Regular比例，衣物与表面需要适配参照；不能把成品默认形象当母亲。Godot工程及源blend属于Source层级，不称全部免费 |
| [Quaternius Universal Animation Library](https://quaternius.com/packs/universalanimationlibrary.html) | 2025-03；120+动作、通用人形绑定、GLB/FBX、CC0；免费与扩展/Source分层 | 走动、站立、坐姿等基础动作 | 候选。确切免费动作须看所下载包；母亲触碰的具体身体行为仍需调整，不能以库数量宣称人物戏解决 |
| [Kenney](https://kenney.nl/support) | 资产页游戏资源CC0，可商用；实际包需看包内许可 | 简单道具基础和操作验证 | 保留基础资源用途。默认低模/可爱外观不作为《极乐迪斯科》式整体风格标准 |
| 工坊的[art-direction-defining-game-art](https://chuangyoushe.games/#/workshop/skills/art-direction-defining-game-art) | 已读详情；主要围绕Sea of Stars邻近像素RPG及Overwatch邻近3D动作；[原仓库](https://github.com/erikhazzard/vasir)首页标MIT | 美术规格/管线资料线索 | 暂不采用。风格范围与当前参照不合，未核原SKILL正文/其完整子资源；平台页面不足以证明成熟生产能力。未执行页面安装命令或生成本项目AGENTS |
| 工坊的Three.js图像/3D/AAA技能 | 工作台卡片指向Three.js和外部生成服务 | 当前Godot画面没有相应消费者 | 本轮不接入。不会为复用一个工具替换引擎或接入新SDK |

## 用到具体资产时

从以上原站定位当前画面需要的单件资源，先看实际外观及规格，再保存资源名/版本或发布日期、原站、许可证和人工调整。免费基础模型与动作可减少重复建设；风格仍由原游戏画面标准约束。音频、UI、付费素材、整套科幻/战斗包不属于本轮需要。

本轮仅研究：未登录、购买、执行站点安装器、下载远程媒体或导入运行资产。此清单已筛出可用入口，但没有证明资产已在Godot可用，更没有完成整体风格。更广的游戏参照调查沿[风格研究](VISUAL_STYLE_REFERENCES.md)继续。

## 真实下载后的修订 / CHG-20261013-025

以上“未下载/未导入”是研究时点。实际Quaternius免费Standard ZIP只有Superhero男女GLTF，没有需要的Regular比例；本轮否决该包的人物接入，不能把网页六种体型当免费包事实。转用MakeHuman系统CC0基础人体/衣物与MPFB v2.0-a3，已导出两份有骨骼GLB并完成Godot定向运行/三帧检查，见[实际资产小样](REAL_ASSET_SAMPLE.md)。工具源GPL3与图形CC0分开；现成算法直接调用，不复制整套工具进游戏。默认服装与纹理仍不适合正式风格，接入通过不等于采用成品外观。
