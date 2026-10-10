# RB-REMOTE-001：独立公开远端与推送

- Status: VERIFYING
- Change: CHG-20261010-002
- Source: [Owner 授权](../governance/sources/2026-10-10-owner-publication.md)

本地发布运维追踪，不冒充 DMCP canonical TASK。不属于游戏功能或资产接入，游戏 L1–L5 N/A。
范围：旧同名 GitHub 库改名保留身份；新 rust-road-song 为 PUBLIC 独立新ID；推送新main并核对远端SHA；更新实际定位、CURRENT/HANDOFF和回执。禁止强推、混入旧历史、提交 .local/凭据、改产品或绕过 DMCP 准入。

验收：两库repository ID不同；旧ID不变/旧main仍9edab66；新visibility PUBLIC；main远端与本地HEAD一致且建立origin/main跟踪；文档入口与定位一致；实际 Git无未提交文件。
