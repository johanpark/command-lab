// CLI와 웹 서버가 함께 쓰는 실습 세션 로직: 시작 → (사용자 실습) → 채점 → 정리
import fs from 'node:fs';
import path from 'node:path';
import { findScenario, loadCatalog, loadTraps } from './catalog.js';
import {
  LAB_ROOT,
  containerName,
  createLabContainer,
  ensureDockerReachable,
  ensureImage,
  execCapture,
  findContainer,
  listLabContainers,
  removeContainer,
} from './docker.js';
import { loadProgress, recordCheck, recordStart } from './progress.js';

export function envFor(catalog, scenario) {
  const env = catalog.envs.find((e) => e.id === scenario.env);
  if (!env) throw new Error(`${scenario.id}: 환경 '${scenario.env}'을(를) 찾을 수 없습니다.`);
  return env;
}

function labEnvVars(scenario, env) {
  return [
    `LEARNER=${env.user}`,
    `LEARNER_HOME=${env.home ?? `/home/${env.user}`}`,
    `SCENARIO_ID=${scenario.id}`,
    `SCENARIO_TITLE=${scenario.title}`,
    `HISTORY_FILE=${[env.history ?? []].flat().join(':')}`,
  ];
}

export async function startScenario(catalog, scenario, { onLog, record = true } = {}) {
  const env = envFor(catalog, scenario);
  await ensureDockerReachable();
  await ensureImage(env, { onLog });
  onLog?.('실습 환경을 만드는 중...');
  const container = await createLabContainer({ scenario, env });
  const vars = labEnvVars(scenario, env);
  const prepare = await execCapture(
    container,
    ['bash', '-c', `sed -i 's/\\r$//' ${LAB_ROOT}/lib/prepare.sh && exec bash ${LAB_ROOT}/lib/prepare.sh`],
    { env: vars },
  );
  if (prepare.exitCode !== 0) {
    throw new Error(`환경 준비 실패:\n${prepare.stdout}${prepare.stderr}`);
  }
  onLog?.('문제 상황을 만드는 중...');
  const setup = await execCapture(container, ['bash', `${LAB_ROOT}/scenario/setup.sh`], { env: vars });
  if (setup.exitCode !== 0) {
    throw new Error(`시나리오 setup.sh 실패:\n${setup.stdout}${setup.stderr}`);
  }
  if (record) recordStart(scenario.id);
  return { name: containerName(scenario.id), env, container };
}

async function runningContainer(scenario) {
  const found = await findContainer(containerName(scenario.id));
  if (!found || !found.info.State.Running) {
    throw new Error(`'${scenario.id}' 실습이 실행 중이 아닙니다. 먼저 시작하세요.`);
  }
  return found.container;
}

// bash 히스토리(HISTTIMEFORMAT 사용 시 '#타임스탬프' 줄이 앞에 붙음)를 파싱한다.
export function parseHistory(text) {
  const items = [];
  let at = null;
  for (const line of text.split('\n')) {
    const ts = line.match(/^#(\d{9,})$/);
    if (ts) {
      at = new Date(Number(ts[1]) * 1000).toISOString();
      continue;
    }
    if (line.trim()) items.push({ at, cmd: line });
    at = null;
  }
  return items;
}

// env.history 는 파일 하나 또는 여러 개(bash + sqlite3 처럼 셸 안의 셸)일 수 있다.
async function readHistory(container, env) {
  const files = [env.history ?? []].flat();
  const all = [];
  for (const file of files) {
    const res = await execCapture(container, ['cat', file], { user: env.user });
    if (res.exitCode === 0) all.push(...parseHistory(res.stdout));
  }
  return all;
}

function runCheck(container, scenario, env) {
  return execCapture(container, ['bash', `${LAB_ROOT}/scenario/check.sh`], { env: labEnvVars(scenario, env) });
}

export async function checkScenario(catalog, scenario) {
  const env = envFor(catalog, scenario);
  const container = await runningContainer(scenario);
  const res = await runCheck(container, scenario, env);
  const history = await readHistory(container, env);
  const passed = res.exitCode === 0;
  const progress = recordCheck(scenario.id, { passed, history });
  return { passed, output: (res.stdout + res.stderr).trimEnd(), history, progress };
}

// 모범 풀이 파일과 그것을 실행할 명령. 셸 종류마다 하나씩 추가하면 된다.
// strict: 모범 풀이는 중간 명령이 하나라도 실패하면 멈춘다. 함정 스크립트는 일부러 실패하는 명령도 있어서 끝까지 간다.
const SOLUTION_RUNNERS = [
  // 학습자의 로그인 셸(lib/profile.sh)과 같은 umask 로 실행한다 (docker exec 기본값은 0000)
  ['solution.sh', (code, strict = true) => ['bash', ...(strict ? ['-e'] : []), '-c', `umask 022\n${code}`]],
  ['solution.ps1', (code, strict = true) => [
    'pwsh', '-NoLogo', '-NoProfile', '-NonInteractive', '-Command',
    `$ErrorActionPreference = '${strict ? 'Stop' : 'Continue'}'\n${code}`,
  ]],
];

function runAsLearner(container, env, cmd) {
  return execCapture(container, cmd, {
    user: env.user,
    workdir: env.workdir,
    env: [`HOME=${env.home ?? `/home/${env.user}`}`, `USER=${env.user}`],
  });
}

const failedLines = (out) => out.split('\n').filter((l) => l.startsWith('✘')).map((l) => l.slice(1).trim());

// 함정·변형 하나: 새 컨테이너 → (모범 풀이) → 함정 스크립트 → 채점 → 기대와 비교
export async function runTrap(catalog, scenario, trap, { onLog } = {}) {
  const [solutionName, toCmd] = SOLUTION_RUNNERS.find(([file]) => fs.existsSync(path.join(scenario.dir, file)));
  const env = envFor(catalog, scenario);
  const { container } = await startScenario(catalog, scenario, { onLog, record: false });
  try {
    const log = [];
    if (trap.afterSolution) {
      const sol = await runAsLearner(container, env, toCmd(fs.readFileSync(path.join(scenario.dir, solutionName), 'utf8')));
      log.push(`--- ${solutionName} ---`, sol.stdout + sol.stderr);
      if (sol.exitCode !== 0) return { ok: false, why: `${solutionName} 실패`, output: log.join('\n') };
    }
    const run = await runAsLearner(container, env, toCmd(trap.code, false));
    log.push(`--- traps/${trap.name} ---`, run.stdout + run.stderr);
    const res = await runCheck(container, scenario, env);
    const out = res.stdout + res.stderr;
    log.push('--- check ---', out);
    const failed = failedLines(out);
    let why = '';
    if (trap.mustPass) {
      if (res.exitCode !== 0) why = `통과해야 하는데 실패: ${failed.join(' / ') || '(✘ 줄 없음)'}`;
    } else if (res.exitCode === 0) {
      why = '실패해야 하는데 통과함';
    } else {
      const missing = trap.mustFail.filter((m) => !failed.some((l) => l.includes(m)));
      if (missing.length) why = `실패 줄에 없음: ${missing.join(', ')} (실제 실패: ${failed.join(' / ') || '없음'})`;
    }
    return { ok: !why, why, output: log.join('\n') };
  } finally {
    await stopScenario(scenario);
  }
}

// 시나리오 자체 검증: 풀기 전엔 채점 실패, 모범 풀이(solution.*) 실행 후엔 통과해야 한다.
// 그다음 traps/ 의 함정은 기대한 줄에서 실패하고, 변형은 통과해야 한다. 학습 기록은 남기지 않는다.
export async function testScenario(catalog, scenario, { onLog, traps = true, onTrap } = {}) {
  const runner = SOLUTION_RUNNERS.find(([file]) => fs.existsSync(path.join(scenario.dir, file)));
  if (!runner) return { skipped: true };
  const [solutionName, toCmd] = runner;
  const env = envFor(catalog, scenario);
  const { container } = await startScenario(catalog, scenario, { onLog, record: false });
  let result;
  try {
    const before = await runCheck(container, scenario, env);
    const code = fs.readFileSync(path.join(scenario.dir, solutionName), 'utf8');
    const solution = await runAsLearner(container, env, toCmd(code));
    const after = await runCheck(container, scenario, env);
    result = {
      ok: before.exitCode !== 0 && solution.exitCode === 0 && after.exitCode === 0,
      beforeFailed: before.exitCode !== 0,
      solutionOk: solution.exitCode === 0,
      afterPassed: after.exitCode === 0,
      traps: [],
      output: [
        '--- check (풀기 전) ---', before.stdout + before.stderr,
        `--- ${solutionName} ---`, solution.stdout + solution.stderr,
        '--- check (풀이 후) ---', after.stdout + after.stderr,
      ].join('\n'),
    };
  } finally {
    await stopScenario(scenario);
  }
  if (result.ok && traps) {
    for (const trap of loadTraps(scenario)) {
      let r;
      try {
        r = await runTrap(catalog, scenario, trap, { onLog });
      } catch (err) {
        r = { ok: false, why: err.message, output: '' };
      }
      const item = { name: trap.name, desc: trap.desc, ...r };
      result.traps.push(item);
      onTrap?.(item);
    }
    result.ok = result.traps.every((t) => t.ok);
  }
  return result;
}

export async function stopScenario(scenario) {
  return removeContainer(containerName(scenario.id));
}

export async function runningScenarioIds() {
  const list = await listLabContainers();
  return list.filter((c) => c.running).map((c) => c.scenarioId);
}

// ID를 생략하면 실행 중인 실습(하나뿐이면 그것, 아니면 가장 최근에 시작한 것)을 고른다.
export async function resolveScenario(catalog, query) {
  if (query) {
    const { scenario, error } = findScenario(catalog.scenarios, query);
    if (error) throw new Error(error);
    return scenario;
  }
  const running = await runningScenarioIds();
  const current = loadProgress().current;
  const pick = running.length === 1 ? running[0] : running.includes(current) ? current : null;
  if (!pick) {
    throw new Error(
      running.length
        ? `실행 중인 실습이 여러 개입니다. ID를 지정하세요: ${running.join(', ')}`
        : '실행 중인 실습이 없습니다. 먼저 `lab start <시나리오>`로 시작하세요.',
    );
  }
  const scenario = catalog.scenarios.find((s) => s.id === pick);
  if (!scenario) throw new Error(`실행 중인 '${pick}' 시나리오를 카탈로그에서 찾을 수 없습니다. lab stop --all 로 정리하세요.`);
  return scenario;
}

export { loadCatalog };
