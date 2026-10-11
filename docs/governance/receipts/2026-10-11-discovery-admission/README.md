# 本次有限文档 Discovery 实际消费

before/dispatch-intent/result/after 为一次新 readiness 的原始请求/回执；report-intent/report-submitted 是固定宿主在共同 canonical 锁下复核并独占写报告的实际记录。不是通用 execute API 或 Owner 验收。

full-readback.json 是实际完整对象/运行观察的公开投影，仅删除 binding.engineRoot/workspacesRoot 两个本机路径。原始快照留本机，摘要和精确省略字段见 consumer-verification.json；对象、basis 与实际 sidecar 未改。不能称该投影原始文件。

上游机制/入口完整 gate 和跨模型静态审查原件在其 docs/verification/discovery-gap。binding SHA 锁政策；本机配置与固定宿主源码/运行 manifest 留私有 host，普通游戏 CLI 仅能读。
