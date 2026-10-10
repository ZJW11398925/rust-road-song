import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const files = execFileSync('git', ['-C', root, 'ls-files', '--cached', '--others', '--exclude-standard'], { encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean);
const failures = [];
for (const file of files) {
  if (!fs.existsSync(path.join(root, file))) { failures.push('缺失文件：' + file); continue; }
  if (!file.endsWith('.md')) continue;
  const text = fs.readFileSync(path.join(root, file), 'utf8');
  if (/^<<<<<<< |^=======\s*$|^>>>>>>> /m.test(text) || text.includes('\uFFFD')) failures.push('冲突或编码损坏：' + file);
  for (const match of text.matchAll(/\[[^\]\n]*\]\(([^)\n]+)\)/g)) {
    const target = match[1].split('#')[0];
    if (!target || /^[a-z]+:/i.test(target)) continue;
    if (!fs.existsSync(path.resolve(root, path.dirname(file), target))) failures.push('断链：' + file + ' → ' + target);
  }
}
const required = ['README.md', 'AGENTS.md', 'docs/DECISION_LOG.md', 'docs/tasks/RB-DISC-001.md', 'docs/governance/binding.json', ...['CURRENT', 'WORKFLOW', 'HANDOFF', 'TOOLING'].map(n => 'docs/governance/' + n + '.md')];
for (const file of required) if (!files.includes(file)) failures.push('缺少项目入口：' + file);
const owner = fs.readFileSync(path.join(root, 'docs/00_OWNER_DECISIONS.md'), 'utf8');
const ids = [...owner.matchAll(/^\| (OD-\d{3}) \|/gm)].map(m => m[1]);
if (ids.length !== 22 || new Set(ids).size !== 22) failures.push('Owner 决定覆盖或编号不完整');
// 建库阶段没有游戏代码。未来实施获审查后应将此限制替换为该阶段的实际门禁。
for (const file of files) if (/(^|\/)(inventory|equipment|bounty_system|shop|crew_jobs|skill_tree|world_state)(\/|$)/.test(file) || /\.(gd|tscn)$/.test(file) || /(^|\/)project\.godot$/.test(file)) failures.push('超出当前文档阶段：' + file);
if (failures.length) { console.error(failures.join('\n')); process.exitCode = 1; }
else console.log('CONTEXT PASS：22 项 Owner 决定、入口/链接、编码、当前范围；不代表玩法或 DMCP 准入。');
