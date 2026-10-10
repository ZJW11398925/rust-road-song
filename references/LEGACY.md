# Legacy 定位与历史边界

身份：rust-road-song-legacy。基线：旧仓库在产品重置前最后提交 `9edab66`（完整哈希见冻结清单），旧本地分支 `feature/VS-M07-130-windows-playtest-export`；最后试玩包名 0.7.183。
这些是建库时读取的历史事实，不是新库运行验证或产品合格结论。

旧 176 为 IN_PROGRESS、L5未覆盖；177/178/179为 BACKLOG；130人工干跑、050目标玩家试玩及已知缺陷未完成。冻结终止路线，不把它们改写为 DONE。

本轮旧库有嵌套的其他会话 worktree，保留旧物理路径，避免破坏历史工作树；本机定位写在忽略的 DMCP host profile 中。Owner后续要求公开新远端，旧GitHub库现已改名为 [rust-road-song-legacy](https://github.com/ZJW11398925/rust-road-song-legacy)，原repository ID1411099328和历史不变。新 [rust-road-song](https://github.com/ZJW11398925/rust-road-song) 是独立ID1412930768、PUBLIC。旧本地origin已更新；旧main仍9edab66，旧冻结提交与本地legacy-0.7.183标签未在本轮推送。旧冻结文档中的“远程未改名”是先前历史检查点，当前远端定位以本文件为准。

任何 Legacy 文件只能作为参考，不能成为产品规范；不通过子模块、目录联接、共享 src 或合并旧历史引入。查看旧模块只读定位，不自动复制。

