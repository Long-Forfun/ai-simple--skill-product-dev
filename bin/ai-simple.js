#!/usr/bin/env node
/* ai-simple — CLI cho lớp máy (deterministic) của phương pháp ai-simple-product-dev.
 * Não (routing /fl, /audit, verify-on-use) sống trong Claude Code skill cùng repo;
 * CLI này cài và bảo trì phần chạy-không-cần-AI: hook, doc-health, templates, workflow.
 * Zero dependency — chỉ Node built-ins. */
'use strict';

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const PKG_ROOT = path.join(__dirname, '..');
const PKG = JSON.parse(fs.readFileSync(path.join(PKG_ROOT, 'package.json'), 'utf8'));
const TPL = (name) => path.join(PKG_ROOT, 'templates', name);

// ---------- helpers ----------
function findSh() {
  // 1. PATH
  const probe = spawnSync(process.platform === 'win32' ? 'where' : 'which', ['sh'], { encoding: 'utf8' });
  if (probe.status === 0 && probe.stdout.trim()) return probe.stdout.trim().split(/\r?\n/)[0];
  // 2. Suy từ git (Git for Windows luôn kèm sh)
  const git = spawnSync('git', ['--exec-path'], { encoding: 'utf8' });
  if (git.status === 0) {
    const execPath = git.stdout.trim(); // ...\Git\mingw64\libexec\git-core
    const candidates = [
      path.join(execPath, '..', '..', '..', 'bin', 'sh.exe'),
      path.join(execPath, '..', '..', '..', 'usr', 'bin', 'sh.exe'),
    ];
    for (const c of candidates) if (fs.existsSync(c)) return c;
  }
  // 3. Vị trí phổ biến trên Windows
  for (const c of ['C:\\Program Files\\Git\\bin\\sh.exe', 'C:\\Program Files\\Git\\usr\\bin\\sh.exe'])
    if (fs.existsSync(c)) return c;
  return null;
}

function sh(scriptAndArgs, opts = {}) {
  const shPath = findSh();
  if (!shPath) return { status: 127, stdout: '', stderr: 'khong tim thay sh (can Git for Windows hoac POSIX shell)' };
  const r = spawnSync(shPath, scriptAndArgs, { encoding: 'utf8', cwd: opts.cwd || process.cwd() });
  return { status: r.status === null ? 1 : r.status, stdout: r.stdout || '', stderr: r.stderr || '' };
}

function git(args, opts = {}) {
  const r = spawnSync('git', args, { encoding: 'utf8', cwd: opts.cwd || process.cwd() });
  return { status: r.status === null ? 1 : r.status, stdout: (r.stdout || '').trim(), stderr: r.stderr || '' };
}

function inGitRepo() { return git(['rev-parse', '--is-inside-work-tree']).status === 0; }

function readVersionMarker(file) {
  try {
    const head = fs.readFileSync(file, 'utf8').split('\n').slice(0, 5).join('\n');
    const m = head.match(/ai-simple-version:\s*([0-9][0-9a-zA-Z.\-]*)/);
    return m ? m[1] : null;
  } catch { return null; }
}

function stampVersion(content) {
  return content.replace(/(ai-simple-version:\s*)[0-9][0-9a-zA-Z.\-]*/, `$1${PKG.version}`);
}

function copyTemplate(src, dest, { force = false, transform = null } = {}) {
  if (fs.existsSync(dest) && !force) return { action: 'SKIP (đã tồn tại — dùng --force để ghi đè, hoặc `update` để nâng cấp giữ config)', dest };
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  let content = fs.readFileSync(src, 'utf8');
  content = stampVersion(content);
  if (transform) content = transform(content);
  fs.writeFileSync(dest, content, 'utf8'); // Node ghi UTF-8 không BOM — an toàn tiếng Việt
  try { fs.chmodSync(dest, 0o755); } catch { /* Windows: không cần */ }
  return { action: 'OK', dest };
}

// LƯU Ý replacement: luôn dùng REPLACER FUNCTION (() => line) thay vì chuỗi —
// config chứa "$'" (vd regex kết thúc $') sẽ bị String.replace hiểu là "phần sau match"
// và nhân bản file (bug bắt được khi tự test v1.1.0).
const STACKS = {
  supabase: null, // default trong template
  prisma: (c) => c
    .replace(/^MIGRATIONS_PATTERN=.*$/m, () => "MIGRATIONS_PATTERN='prisma/migrations/.*\\.sql$'")
    .replace(/^SELF_TEST_MIGRATION_SAMPLE=.*$/m, () => "SELF_TEST_MIGRATION_SAMPLE='prisma/migrations/20240101000000_init/migration.sql'"),
  custom: (c) => c, // giữ default, người dùng tự sửa CONFIG — doctor sẽ nhắc qua self-test
};

const FILES = [
  { tpl: 'CLAUDE.md.template',               dest: 'CLAUDE.md',                              stackable: false },
  { tpl: 'app-map-README.md.template',       dest: 'docs/app-map/README.md',                 stackable: false },
  { tpl: 'pre-commit.hook.template',         dest: '.githooks/pre-commit',                   stackable: true  },
  { tpl: 'doc-health-report.sh.template',    dest: 'scripts/doc-health-report.sh',           stackable: false },
  { tpl: 'fl.command.md.template',           dest: '.claude/commands/fl.md',                 stackable: false },
  { tpl: 'audit.command.md.template',        dest: '.claude/commands/audit.md',              stackable: false },
  { tpl: 'context-router.agent.md.template', dest: '.claude/agents/context-router.md',       stackable: false },
  { tpl: 'doc-health.workflow.yml.template', dest: '.github/workflows/doc-health.yml',       stackable: false, optionalFlag: 'no-workflow' },
  // Bộ template viết-doc để dành trong repo (copy khi cần viết doc mới)
  { tpl: 'app-map-doc.md.template',          dest: 'docs/_templates/app-map-doc.md.template',          stackable: false },
  { tpl: 'ADR.md.template',                  dest: 'docs/_templates/ADR.md.template',                  stackable: false },
  { tpl: 'runbook.md.template',              dest: 'docs/_templates/runbook.md.template',              stackable: false },
  { tpl: 'state-registry.md.template',       dest: 'docs/_templates/state-registry.md.template',       stackable: false },
  { tpl: 'ops-schedules.md.template',        dest: 'docs/_templates/ops-schedules.md.template',        stackable: false },
  { tpl: 'ops-external-services.md.template',dest: 'docs/_templates/ops-external-services.md.template',stackable: false },
  { tpl: 'contract-doc.md.template',         dest: 'docs/_templates/contract-doc.md.template',         stackable: false },
];

function runSelfTests() {
  const results = [];
  if (fs.existsSync('.githooks/pre-commit')) {
    const r = sh(['.githooks/pre-commit', '--self-test']);
    results.push({ name: 'hook --self-test', ok: r.status === 0, out: r.stdout + r.stderr });
  } else results.push({ name: 'hook --self-test', ok: false, out: '.githooks/pre-commit không tồn tại' });
  if (fs.existsSync('scripts/doc-health-report.sh')) {
    const r = sh(['scripts/doc-health-report.sh', '--self-test']);
    results.push({ name: 'report --self-test', ok: r.status === 0, out: r.stdout + r.stderr });
  } else results.push({ name: 'report --self-test', ok: false, out: 'scripts/doc-health-report.sh không tồn tại' });
  return results;
}

// ---------- commands ----------
function cmdInit(args) {
  if (!inGitRepo()) { console.error('FAIL: không phải git repo. Chạy `git init` trước — toàn bộ enforcement sống trên git.'); process.exit(1); }
  const stack = (args.stack || 'supabase').toLowerCase();
  if (!(stack in STACKS)) { console.error(`FAIL: --stack phải là ${Object.keys(STACKS).join('|')}`); process.exit(1); }
  console.log(`ai-simple v${PKG.version} — init (stack: ${stack})\n`);

  for (const f of FILES) {
    if (f.optionalFlag && args[f.optionalFlag]) { console.log(`  SKIP  ${f.dest} (--${f.optionalFlag})`); continue; }
    const transform = f.stackable ? STACKS[stack] : null;
    const r = copyTemplate(TPL(f.tpl), f.dest, { force: !!args.force, transform });
    console.log(`  ${r.action === 'OK' ? 'OK   ' : 'SKIP '} ${f.dest}${r.action.startsWith('SKIP') ? ' — đã tồn tại' : ''}`);
  }

  const hp = git(['config', 'core.hooksPath', '.githooks']);
  console.log(`  ${hp.status === 0 ? 'OK   ' : 'FAIL '} git config core.hooksPath .githooks`);

  console.log('\nSelf-test (tin instrument sau khi nó tự chứng minh):');
  let failed = false;
  for (const t of runSelfTests()) {
    console.log(`  ${t.ok ? 'PASS ' : 'FAIL '} ${t.name}`);
    if (!t.ok) { failed = true; console.log(t.out.split('\n').map((l) => '        ' + l).join('\n')); }
  }
  if (stack === 'custom') console.log('\nLƯU Ý stack custom: sửa CONFIG trong .githooks/pre-commit (MIGRATIONS_PATTERN, SELF_TEST_*) rồi chạy `ai-simple doctor`.');
  console.log('\nTiếp theo: điền placeholder {{...}} trong CLAUDE.md; doc gắn code khai covers:/last_verified:/ttl_days:;');
  console.log('máy clone mới chỉ cần chạy lại: git config core.hooksPath .githooks (hoặc `ai-simple doctor` sẽ nhắc).');
  process.exit(failed ? 1 : 0);
}

function cmdDoctor() {
  console.log(`ai-simple v${PKG.version} — doctor\n`);
  const checks = [];
  const add = (name, status, note = '') => checks.push({ name, status, note });

  add('git repo', inGitRepo() ? 'PASS' : 'FAIL', inGitRepo() ? '' : 'chạy git init');
  const hp = git(['config', 'core.hooksPath']);
  add('core.hooksPath = .githooks', hp.stdout === '.githooks' ? 'PASS' : 'FAIL', hp.stdout ? `đang là '${hp.stdout}'` : 'chưa set — hook KHÔNG chạy; `git config core.hooksPath .githooks`');

  for (const [file, label] of [['.githooks/pre-commit', 'hook'], ['scripts/doc-health-report.sh', 'doc-health-report']]) {
    if (!fs.existsSync(file)) { add(`${label} tồn tại`, 'FAIL', `thiếu ${file} — chạy \`ai-simple init\``); continue; }
    add(`${label} tồn tại`, 'PASS');
    const v = readVersionMarker(file);
    if (v === PKG.version) add(`${label} version ${v}`, 'PASS');
    else add(`${label} version`, 'WARN', `bản cài ${v || 'không rõ'} ≠ CLI ${PKG.version} — chạy \`ai-simple update\` (giữ nguyên CONFIG)`);
  }

  for (const t of runSelfTests()) add(t.name, t.ok ? 'PASS' : 'FAIL', t.ok ? '' : t.out.split('\n').find((l) => l.includes('FAIL')) || 'xem output');

  if (fs.existsSync('CLAUDE.md')) {
    const size = fs.statSync('CLAUDE.md').size;
    add(`CLAUDE.md ${size} chars`, size <= 24000 ? 'PASS' : 'WARN', size > 24000 ? 'vượt budget ~6K tokens — root diet (nguyên tắc 01)' : '');
  } else add('CLAUDE.md', 'WARN', 'chưa có — AI session mới sẽ mù context');

  if (fs.existsSync('docs/app-map')) {
    const docs = [];
    (function walk(d) { for (const e of fs.readdirSync(d, { withFileTypes: true })) { const p = path.join(d, e.name); if (e.isDirectory() && e.name !== '_generated') walk(p); else if (e.name.endsWith('.md')) docs.push(p); } })('docs/app-map');
    const withCovers = docs.filter((d) => { try { return /^covers:/im.test(fs.readFileSync(d, 'utf8').split('\n').slice(0, 10).join('\n')); } catch { return false; } });
    add(`app-map: ${docs.length} docs, ${withCovers.length} có covers`, withCovers.length > 0 || docs.length <= 1 ? 'PASS' : 'WARN', withCovers.length === 0 && docs.length > 1 ? 'doc gắn code chưa khai covers: — nằm ngoài 2 cổng bảo vệ (nguyên tắc 12)' : '');
    add('doc-status.md', fs.existsSync('docs/app-map/_generated/doc-status.md') ? 'PASS' : 'WARN', fs.existsSync('docs/app-map/_generated/doc-status.md') ? '' : 'chưa sinh — chạy `ai-simple doc-status` (cổng đọc cần file này)');
  } else add('docs/app-map', 'WARN', 'chưa có — chạy `ai-simple init`');

  let fail = 0;
  for (const c of checks) {
    console.log(`  ${c.status.padEnd(5)} ${c.name}${c.note ? ' — ' + c.note : ''}`);
    if (c.status === 'FAIL') fail++;
  }
  console.log(`\n${fail === 0 ? 'OK: setup lành mạnh.' : `FAIL: ${fail} mục hỏng — sửa theo ghi chú trên.`}`);
  process.exit(fail === 0 ? 0 : 1);
}

function cmdUpdate(args) {
  if (!inGitRepo()) { console.error('FAIL: không phải git repo.'); process.exit(1); }
  console.log(`ai-simple v${PKG.version} — update (giữ nguyên CONFIG người dùng)\n`);
  const PRESERVE = {
    '.githooks/pre-commit': ['MIGRATIONS_PATTERN=', 'DB_DOC_PATTERN=', 'CLAUDE_MD_CHAR_BUDGET=', 'SELF_TEST_MIGRATION_SAMPLE=', 'SELF_TEST_DOC_SAMPLE='],
    'scripts/doc-health-report.sh': ['MIGRATIONS_DIR=', 'DOC_LAG_MAX_DAYS='],
  };
  const SRC = { '.githooks/pre-commit': 'pre-commit.hook.template', 'scripts/doc-health-report.sh': 'doc-health-report.sh.template' };

  for (const [dest, keys] of Object.entries(PRESERVE)) {
    const preserved = {};
    if (fs.existsSync(dest)) {
      const old = fs.readFileSync(dest, 'utf8');
      for (const k of keys) { const m = old.match(new RegExp(`^${k}.*$`, 'm')); if (m) preserved[k] = m[0]; }
      fs.copyFileSync(dest, dest + '.bak');
    }
    let content = stampVersion(fs.readFileSync(TPL(SRC[dest]), 'utf8'));
    for (const [k, line] of Object.entries(preserved)) content = content.replace(new RegExp(`^${k}.*$`, 'm'), () => line);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, content, 'utf8');
    try { fs.chmodSync(dest, 0o755); } catch {}
    console.log(`  OK    ${dest} → v${PKG.version} (config giữ: ${Object.keys(preserved).length}/${keys.length}; bản cũ: ${dest}.bak)`);
  }
  if (fs.existsSync('.github/workflows/doc-health.yml') || args.workflow) {
    const r = copyTemplate(TPL('doc-health.workflow.yml.template'), '.github/workflows/doc-health.yml', { force: true });
    console.log(`  OK    ${r.dest}`);
  }
  console.log('\nSelf-test:');
  let failed = false;
  for (const t of runSelfTests()) { console.log(`  ${t.ok ? 'PASS ' : 'FAIL '} ${t.name}`); if (!t.ok) { failed = true; console.log(t.out.split('\n').map((l) => '        ' + l).join('\n')); } }
  if (failed) console.log('\nFAIL: rollback bằng file .bak nếu cần (mv .bak về tên cũ).');
  process.exit(failed ? 1 : 0);
}

function passthrough(scriptArgs) {
  if (!fs.existsSync('scripts/doc-health-report.sh')) { console.error('FAIL: thiếu scripts/doc-health-report.sh — chạy `ai-simple init` trước.'); process.exit(1); }
  const r = sh(['scripts/doc-health-report.sh', ...scriptArgs]);
  process.stdout.write(r.stdout); process.stderr.write(r.stderr);
  process.exit(r.status);
}

function cmdSelfTest() { // dùng cho `npm test` của chính package: chạy self-test 2 template từ package
  let failed = false;
  for (const [label, file, arg] of [['hook', TPL('pre-commit.hook.template'), '--self-test'], ['report', TPL('doc-health-report.sh.template'), '--self-test']]) {
    const r = sh([file, arg], { cwd: PKG_ROOT });
    console.log(`${r.status === 0 ? 'PASS' : 'FAIL'} template ${label} --self-test`);
    if (r.status !== 0) { failed = true; console.log(r.stdout + r.stderr); }
  }
  process.exit(failed ? 1 : 0);
}

// ---------- arg parsing & dispatch ----------
function parse(argv) {
  const args = { _: [] };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const key = a.slice(2);
      if (i + 1 < argv.length && !argv[i + 1].startsWith('--') && ['stack'].includes(key)) args[key] = argv[++i];
      else args[key] = true;
    } else args._.push(a);
  }
  return args;
}

const HELP = `ai-simple v${PKG.version} — lớp máy của phương pháp ai-simple-product-dev
(não — /fl, /audit, verify-on-use — sống trong Claude Code skill cùng repo)

Usage:
  npx ai-simple init [--stack supabase|prisma|custom] [--force] [--no-workflow]
      Cài hook + doc-health + templates + workflow vào repo hiện tại, set hooksPath, chạy self-test.
  npx ai-simple doctor
      Khám setup: hooksPath, version drift, self-tests, budget CLAUDE.md, covers coverage.
  npx ai-simple update [--workflow]
      Nâng hook + report lên bản CLI này, GIỮ NGUYÊN config người dùng (backup .bak).
  npx ai-simple doc-status
      Regenerate docs/app-map/_generated/doc-status.md (+ marker DOC-STATUS trong doc).
  npx ai-simple doc-health [--ci]
      Report doc-lag/ORPHANED/symbol chết/broken ref; --ci exit 1 để fail PR.
  npx ai-simple version | help

Sau khi init, hệ chạy theo SỰ KIỆN — không có lệnh nào phải nhớ:
commit → hook chặn sai; PR → CI fail nếu doc-lag; AI đọc doc → cổng đọc bắt verify.`;

const args = parse(process.argv.slice(2));
const cmd = args._[0] || 'help';
switch (cmd) {
  case 'init': cmdInit(args); break;
  case 'doctor': cmdDoctor(); break;
  case 'update': cmdUpdate(args); break;
  case 'doc-status': passthrough(['--status']); break;
  case 'doc-health': passthrough(args.ci ? ['--ci'] : []); break;
  case 'self-test': cmdSelfTest(); break;
  case 'version': case '--version': case '-v': console.log(PKG.version); break;
  default: console.log(HELP);
}
