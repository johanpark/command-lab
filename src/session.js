// CLI와 웹 서버가 함께 쓰는 실습 세션 로직: 시작 → (사용자 실습) → 채점 → 정리
import fs from 'node:fs';
import path from 'node:path';
import { findScenario, loadCatalog } from './catalog.js';
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
    `HISTORY_FILE=${env.history}`,
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

async function readHistory(container, env) {
  if (!env.history) return [];
  const res = await execCapture(container, ['cat', env.history], { user: env.user });
  return res.exitCode === 0 ? parseHistory(res.stdout) : [];
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
const SOLUTION_RUNNERS = [
  ['solution.sh', (code) => ['bash', '-e', '-c', code]],
  ['solution.ps1', (code) => ['pwsh', '-NoLogo', '-NoProfile', '-NonInteractive', '-Command', `$ErrorActionPreference = 'Stop'\n${code}`]],
];

// 시나리오 자체 검증: 풀기 전엔 채점 실패, 모범 풀이(solution.*) 실행 후엔 통과해야 한다.
// 학습 기록은 남기지 않는다.
export async function testScenario(catalog, scenario, { onLog } = {}) {
  const runner = SOLUTION_RUNNERS.find(([file]) => fs.existsSync(path.join(scenario.dir, file)));
  if (!runner) return { skipped: true };
  const [solutionName, toCmd] = runner;
  const env = envFor(catalog, scenario);
  const { container } = await startScenario(catalog, scenario, { onLog, record: false });
  try {
    const before = await runCheck(container, scenario, env);
    const code = fs.readFileSync(path.join(scenario.dir, solutionName), 'utf8');
    const solution = await execCapture(container, toCmd(code), {
      user: env.user,
      workdir: env.workdir,
      env: [`HOME=${env.home ?? `/home/${env.user}`}`, `USER=${env.user}`],
    });
    const after = await runCheck(container, scenario, env);
    return {
      ok: before.exitCode !== 0 && solution.exitCode === 0 && after.exitCode === 0,
      beforeFailed: before.exitCode !== 0,
      solutionOk: solution.exitCode === 0,
      afterPassed: after.exitCode === 0,
      output: [
        '--- check (풀기 전) ---', before.stdout + before.stderr,
        `--- ${solutionName} ---`, solution.stdout + solution.stderr,
        '--- check (풀이 후) ---', after.stdout + after.stderr,
      ].join('\n'),
    };
  } finally {
    await stopScenario(scenario);
  }
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
