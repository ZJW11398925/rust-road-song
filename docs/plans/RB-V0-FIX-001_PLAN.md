# RB-V0-FIX-001 / CHG-20261013-013

PLAYER NEED：A/D必须按车辆自身左右工作，不能反向。

NARRATIVE / GAMEPLAY CONTEXT：当前首见POC已启动短驶出，非离家。

MINIMUM IMPLEMENTATION：只反转驾驶转向符号，增加实际输入前进/倒车A/D方向角及位移探针；保持原89断言。十路径沿当前visual_v0工程及报告，独立新准入。

WHY NOT LESS：旧碰撞检查无法验证左右，只有符号变化没有真实输入证明也不足。

LEGACY DEPENDENCY：NONE。旧34冻结。

先取得新READY，测试修前RED，再修后GREEN和真实渲染，独立核验、提交推送。造型反馈继续开放。
