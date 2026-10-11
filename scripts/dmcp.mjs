import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { assertReadRequest } from './lib/scope.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const json = p => JSON.parse(fs.readFileSync(p, 'utf8'));
const binding = json(path.join(root, 'docs/governance/binding.json'));
const profile = json(path.join(root, binding.localProfile));
const [mode, requestPath] = process.argv.slice(2);
if (!['read', 'tools', 'get'].includes(mode)) throw Error('用法：node scripts/dmcp.mjs read | tools | get request.json；本工具不写 DMCP。');
if (path.resolve(profile.repositoryRoot).toLowerCase() !== root.toLowerCase()) throw Error('本机配置指向其他仓库。');
for (const [relative, expected] of Object.entries(binding.toolingFiles)) {
  const actual = crypto.createHash('sha256').update(fs.readFileSync(path.join(profile.toolchainRoot, relative))).digest('hex');
  if (actual !== expected) throw Error('DMCP 工具链已漂移：' + relative + '；先审查再更新绑定。');
}
const engineCommit = execFileSync('git', ['-C', profile.engineRoot, 'rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
if (engineCommit !== binding.engineCommit) throw Error('DMCP 引擎版本已漂移；先审查再更新绑定。');
if (binding.documentDiscoveryPolicySha256) {
  if (!profile.readinessPolicyFile) throw Error('缺少受审 Discovery 政策的本机配置。');
  const actual = crypto.createHash('sha256').update(fs.readFileSync(profile.readinessPolicyFile)).digest('hex');
  if (actual !== binding.documentDiscoveryPolicySha256) throw Error('Discovery 政策已漂移；先审查再更新绑定。');
}
const load = relative => import(pathToFileURL(path.join(profile.toolchainRoot, relative)).href);
const { dmcpConfigFromEnv } = await load('services/knowledge/src/dmcp/config.ts');
const config = dmcpConfigFromEnv({
  KNOWLEDGE_DMCP_REPO_ROOT: profile.engineRoot,
  KNOWLEDGE_DMCP_WORKSPACES_ROOT: profile.workspacesRoot,
  KNOWLEDGE_DMCP_PRINCIPAL_TYPE: 'SERVICE',
  KNOWLEDGE_DMCP_PRINCIPAL_ID: 'rust-road-song-governance-reader',
  KNOWLEDGE_DMCP_GRANTED_CAPABILITY_FAMILIES: 'DESIGN_STATE_READ,REPOSITORY_READ',
});
if (binding.documentDiscoveryPolicySha256) config.env.DMCP_READINESS_POLICY_FILE = profile.readinessPolicyFile;
if (mode === 'tools') {
  const { DmcpWireClient } = await load('services/knowledge/src/dmcp/wire-client.ts');
  const wire = new DmcpWireClient({ command: config.command, args: config.args, cwd: config.cwd, env: config.env, timeoutMs: 20000 });
  try {
    await wire.start();
    console.log(JSON.stringify(await wire.request('tools/list', {}), null, 2));
  } finally { wire.dispose(); }
} else {
  const request = mode === 'get' ? json(path.resolve(requestPath ?? '')) : null;
  if (mode === 'get') assertReadRequest(request, binding.workspaceId);
  const { DmcpClient } = await load('services/knowledge/src/dmcp/client.ts');
  const client = new DmcpClient(config);
  try {
    await client.start();
    if (mode === 'get') console.log(JSON.stringify(await client.callTool(request.tool, request.arguments), null, 2));
    else {
      const { createHostSnapshotReader, readGovernanceSnapshot } = await load('scripts/lib/dmcp-governance-snapshot.mjs');
      const hostBinding = { ...binding, engineRoot: profile.engineRoot, workspacesRoot: profile.workspacesRoot };
      const readHostSnapshot = await createHostSnapshotReader(hostBinding, config.env);
      const snapshot = await readGovernanceSnapshot({ binding: hostBinding, client, readHostSnapshot });
      console.log(JSON.stringify(snapshot, null, 2));
    }
  } finally { client.dispose(); }
}
