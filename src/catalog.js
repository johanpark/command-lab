// 환경(envs/)과 시나리오(scenarios/)를 디스크에서 읽어 카탈로그로 만든다.
// 새 환경/시나리오는 디렉터리만 추가하면 자동으로 인식된다.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import YAML from 'yaml';

export const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
export const ENVS_DIR = path.join(ROOT, 'envs');
export const SCENARIOS_DIR = path.join(ROOT, 'scenarios');
export const LIB_DIR = path.join(ROOT, 'lib');

const ENV_DEFAULTS = {
  shell: ['bash', '-l'],
  user: 'learner',
  workdir: '/home/learner',
  history: '/home/learner/.bash_history',
  hostname: 'lab',
  order: 100,
};

// 파일 하나가 깨져도 나머지는 쓸 수 있게, 읽기 오류는 모아 두고 건너뛴다.
export const loadErrors = [];

function readYaml(file) {
  try {
    return YAML.parse(fs.readFileSync(file, 'utf8')) ?? {};
  } catch (err) {
    loadErrors.push(`${path.relative(ROOT, file)}: ${err.message.split('\n')[0]}`);
    return null;
  }
}

function subdirs(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((d) => d.isDirectory() && !d.name.startsWith('_') && !d.name.startsWith('.'))
    .map((d) => d.name)
    .sort();
}

export function loadEnvs() {
  const envs = [];
  for (const name of subdirs(ENVS_DIR)) {
    const dir = path.join(ENVS_DIR, name);
    const file = path.join(dir, 'env.yaml');
    if (!fs.existsSync(file)) continue;
    const meta = readYaml(file);
    if (!meta) continue;
    envs.push({
      ...ENV_DEFAULTS,
      ...meta,
      id: name,
      name: meta.name ?? name,
      description: meta.description ?? '',
      icon: meta.icon ?? '💻',
      // 시나리오를 묶어 보여줄 카테고리 (scenario.yaml 의 category 값과 연결)
      categories: (meta.categories ?? []).map((c) => ({ icon: '📌', description: '', ...c })),
      dir,
      image: `cmdlab-env-${name}:latest`,
    });
  }
  return envs.sort((a, b) => a.order - b.order || a.id.localeCompare(b.id));
}

export function loadScenarios() {
  const scenarios = [];
  for (const group of subdirs(SCENARIOS_DIR)) {
    for (const name of subdirs(path.join(SCENARIOS_DIR, group))) {
      const dir = path.join(SCENARIOS_DIR, group, name);
      const file = path.join(dir, 'scenario.yaml');
      if (!fs.existsSync(file)) continue;
      const meta = readYaml(file);
      if (!meta) continue;
      scenarios.push({
        id: `${group}/${name}`,
        title: meta.title ?? name,
        env: meta.env ?? group,
        level: meta.level ?? 1,
        minutes: meta.minutes ?? 10,
        category: meta.category ?? 'etc',
        tags: meta.tags ?? [],
        summary: meta.summary ?? '',
        dir,
      });
    }
  }
  return scenarios;
}

export function loadCatalog() {
  loadErrors.length = 0;
  const envs = loadEnvs();
  const scenarios = loadScenarios();
  const envOrder = new Map(envs.map((e, i) => [e.id, i]));
  scenarios.sort(
    (a, b) =>
      (envOrder.get(a.env) ?? 99) - (envOrder.get(b.env) ?? 99) ||
      a.id.localeCompare(b.id),
  );
  return { envs, scenarios };
}

function readOptional(file) {
  return fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : '';
}

// 문제 설명, 단계별 힌트('---' 줄로 구분), 해설
export function readScenarioDocs(scenario) {
  const hints = readOptional(path.join(scenario.dir, 'hints.md'))
    .split(/^---\s*$/m)
    .map((h) => h.trim())
    .filter(Boolean);
  return {
    task: readOptional(path.join(scenario.dir, 'task.md')),
    hints,
    debrief: readOptional(path.join(scenario.dir, 'debrief.md')),
  };
}

// 함정·변형 테스트 (traps/*.sh, *.ps1): 맨 위 '#' 주석 줄에 기대 결과를 적는다.
//   # 설명: 무엇을 확인하는지
//   # 모범 풀이 먼저          ← (선택) 모범 풀이를 실행한 뒤 이 스크립트를 실행
//   # 실패해야: 문구          ← 채점 출력에 이 문구가 든 ✘ 줄이 있어야 한다 (여러 줄 가능)
//   # 통과해야               ← 다르게 풀어도 맞는 풀이: 채점이 통과해야 한다
export const TRAP_EXTS = ['.sh', '.ps1'];

export function parseTrap(file) {
  const text = fs.readFileSync(file, 'utf8').replace(/\r\n/g, '\n');
  const trap = { name: path.basename(file), file, desc: '', afterSolution: false, mustFail: [], mustPass: false, problems: [] };
  for (const line of text.split('\n')) {
    if (line.startsWith('#!')) continue;
    if (!line.startsWith('#')) break;
    const body = line.replace(/^#\s?/, '').trim();
    let m;
    if ((m = body.match(/^설명:\s*(.+)$/))) trap.desc = m[1];
    else if (body === '모범 풀이 먼저') trap.afterSolution = true;
    else if ((m = body.match(/^실패해야:\s*(.+)$/))) trap.mustFail.push(m[1]);
    else if (body === '통과해야') trap.mustPass = true;
  }
  trap.code = text;
  if (!trap.desc) trap.problems.push('# 설명: 줄이 없습니다');
  if (trap.mustPass === Boolean(trap.mustFail.length)) {
    trap.problems.push('# 실패해야: 문구 와 # 통과해야 중 하나만 있어야 합니다');
  }
  return trap;
}

export function loadTraps(scenario) {
  const dir = path.join(scenario.dir, 'traps');
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => TRAP_EXTS.includes(path.extname(f)))
    .sort()
    .map((f) => parseTrap(path.join(dir, f)));
}

// "linux/03" 처럼 일부만 입력해도 하나로 특정되면 찾아준다.
export function findScenario(scenarios, query) {
  if (!query) return { error: '시나리오 ID를 입력하세요.' };
  const exact = scenarios.find((s) => s.id === query);
  if (exact) return { scenario: exact };
  const q = query.toLowerCase();
  const matches = scenarios.filter(
    (s) => s.id.toLowerCase().startsWith(q) || s.id.toLowerCase().includes(q),
  );
  if (matches.length === 1) return { scenario: matches[0] };
  if (matches.length === 0) return { error: `'${query}'에 해당하는 시나리오가 없습니다.` };
  return {
    error: `'${query}'에 해당하는 시나리오가 여러 개입니다: ${matches.map((s) => s.id).join(', ')}`,
  };
}

// 카탈로그 구조 검사 (lab validate)
export function validateCatalog() {
  const { envs, scenarios } = loadCatalog();
  const problems = [...loadErrors];
  for (const env of envs) {
    if (!fs.existsSync(path.join(env.dir, 'Dockerfile'))) {
      problems.push(`env ${env.id}: Dockerfile이 없습니다.`);
    }
    if (!Array.isArray(env.shell)) problems.push(`env ${env.id}: shell은 배열이어야 합니다.`);
  }
  for (const s of scenarios) {
    const env = envs.find((e) => e.id === s.env);
    if (!env) problems.push(`${s.id}: 존재하지 않는 env '${s.env}'`);
    else if (env.categories.length && !env.categories.some((c) => c.id === s.category)) {
      problems.push(`${s.id}: env '${s.env}' 에 없는 category '${s.category}'`);
    }
    for (const f of ['task.md', 'setup.sh', 'check.sh']) {
      if (!fs.existsSync(path.join(s.dir, f))) problems.push(`${s.id}: ${f} 파일이 없습니다.`);
    }
    for (const f of ['setup.sh', 'check.sh']) {
      const p = path.join(s.dir, f);
      if (fs.existsSync(p) && fs.readFileSync(p, 'utf8').includes('\r\n')) {
        problems.push(`${s.id}: ${f}에 CRLF 줄바꿈이 있습니다.`);
      }
    }
    const solution = TRAP_EXTS.map((e) => `solution${e}`).find((f) => fs.existsSync(path.join(s.dir, f)));
    for (const t of loadTraps(s)) {
      t.problems.forEach((p) => problems.push(`${s.id}: traps/${t.name}: ${p}`));
      if (solution && path.extname(t.name) !== path.extname(solution)) {
        problems.push(`${s.id}: traps/${t.name}: 모범 풀이(${solution})와 같은 종류(${path.extname(solution)})여야 합니다.`);
      }
      if (t.afterSolution && !solution) problems.push(`${s.id}: traps/${t.name}: '모범 풀이 먼저' 인데 solution 파일이 없습니다.`);
    }
  }
  return { envs, scenarios, problems };
}
