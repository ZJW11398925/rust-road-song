// 本入口仅负责新项目的读取边界；写入和组织裁决不在其能力中。
export function assertReadRequest(request, workspaceId) {
  if (!request || Array.isArray(request) || !['design_status', 'design_get', 'finding_list'].includes(request.tool)) {
    throw Error('只允许 design_status / design_get / finding_list。');
  }
  const args = request.arguments;
  if (!args || Array.isArray(args) || args.workspace_ref?.workspace_id !== workspaceId) {
    throw Error('请求必须明确绑定本项目 workspace_id。');
  }
  function inspect(value) {
    if (!value || typeof value !== 'object') return;
    for (const [key, item] of Object.entries(value)) {
      if (key === 'workspace_id' && item !== workspaceId) throw Error('拒绝嵌套跨项目引用。');
      inspect(item);
    }
  }
  inspect(args);
}
