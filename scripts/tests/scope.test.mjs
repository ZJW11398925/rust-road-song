import test from 'node:test';
import assert from 'node:assert/strict';
import { assertReadRequest } from '../lib/scope.mjs';

const bound = 'ws-new';
const valid = () => ({ tool: 'design_get', arguments: { workspace_ref: { workspace_id: bound }, refs: [{ kind: 'DECISION', id: 'DEC-1' }] } });
test('本项目读取可通过', () => assert.doesNotThrow(() => assertReadRequest(valid(), bound)));
test('拒绝缺失身份及其他项目', () => {
  assert.throws(() => assertReadRequest({ tool: 'design_status', arguments: {} }, bound));
  const request = valid(); request.arguments.workspace_ref.workspace_id = 'ws-old';
  assert.throws(() => assertReadRequest(request, bound));
});
test('递归检查数组中的跨项目引用', () => {
  const request = valid(); request.arguments.refs[0].nested = [{ workspace_id: 'ws-old' }];
  assert.throws(() => assertReadRequest(request, bound));
});
test('读取入口不能创建、裁决、写入或查询准入', () => {
  for (const tool of ['design_create', 'decision_add', 'finding_adjudicate', 'design_readiness', 'task_build']) {
    const request = valid(); request.tool = tool;
    assert.throws(() => assertReadRequest(request, bound));
  }
});
test('拒绝损坏请求而非静默补默认值', () => {
  for (const request of [null, [], {}, { tool: 'design_get', arguments: null }]) assert.throws(() => assertReadRequest(request, bound));
});
