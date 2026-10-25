#!/usr/bin/env node
// command-lab CLI
import { loadCatalog, loadErrors, readScenarioDocs, validateCatalog } from '../src/catalog.js';
import {
  attachShellInteractive,
  buildImage,
  containerName,
  ensureDockerReachable,
  imageStatus,
  listLabContainers,
  removeContainer,
} from '../src/docker.js';
import { loadProgress, scenarioStatus, setCurrent } from '../src/progress.js';
import {
  checkScenario,
  envFor,
  resolveScenario,
  runningScenarioIds,
  startScenario,
  stopScenario,
  testScenario,
} from '../src/session.js';

const color = (code) => (s) => (process.stdout.isTTY ? `\x1b[${code}m${s}\x1b[0m` : String(s));
const c = {
  bold: color('1'),
  dim: color('2'),
  red: color('31'),
  green: color('32'),
  yellow: color('33'),
  cyan: color('36'),
  magenta: color('35'),
};

const HELP = `
${c.bold('command-lab')} — 실제 CLI 환경에서 상황별로 명령어를 연습하는 실습장

${c.bold('기본 흐름')}
  lab list                 시나리오 목록 보기
  lab start <시나리오>     실습 시작 → 문제 확인 → 셸 접속 (exit 하면 자동 채점)
  lab web [--open]         같은 실습을 브라우저에서 (http://localhost:4000)

${c.bold('실습 중')}
  lab shell [시나리오]     실행 중인 실습 셸에 다시 들어가기
  lab check [시나리오]     채점하고 기록 저장
  lab task  [시나리오]     문제 다시 보기
  lab hint  [시나리오] [n] n번째 힌트 (생략 시 1번)
  lab reset [시나리오]     처음 상태로 되돌리기
  lab solution [시나리오]  해설 보기 (통과 후 권장)
  lab stop  [시나리오]     실습 종료 (--all: 모두)

${c.bold('기록 / 관리')}
  lab status               진행 상황과 복습 예정
  lab review               지금 복습할 시나리오 추천
  lab envs                 환경(연습할 CLI 종류) 목록
  lab build [환경|--all]   환경 이미지 미리 빌드 (--no-cache)
  lab validate             시나리오 파일 구조 검사
  lab test [시나리오|환경]  모범 풀이로 시나리오 자동 검증 (시나리오 작성자용)

시나리오는 ID 일부만 써도 됩니다. 예) lab start linux/01
`;

function renderMarkdown(md) {
  let inCode = false;
  return md
    .split('\n')
    .map((line) => {
      if (line.startsWith('```')) {
        inCode = !inCode;
        return null;
      }
      if (inCode) return `    ${c.green(line)}`;
      if (/^#{1,6}\s/.test(line)) return c.bold(c.cyan(line.replace(/^#+\s*/, '')));
      if (/^\|?\s*-{3,}/.test(line)) return null;
      return line
        .replace(/^>\s?/, '  ')
        .replace(/`([^`]+)`/g, (_, code) => c.yellow(code)).replace(/\*\*([^*]+)\*\*/g, (_, b) => c.bold(b));
    })
    .filter((l) => l !== null)
    .join('\n');
}

const STATE_LABEL = {
  new: c.dim('·  '),
  tried: c.yellow('…  '),
  done: c.green('✔  '),
  review: c.magenta('↻  '),
};

function parseArgs(argv) {
  const positional = [];
  const flags = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const [k, v] = a.slice(2).split('=');
      if (v !== undefined) flags[k] = v;
      else if (argv[i + 1] && !argv[i + 1].startsWith('-') && ['port', 'host'].includes(k)) flags[k] = argv[++i];
      else flags[k] = true;
    } else if (a === '-y') flags.yes = true;
    else positional.push(a);
  }
  return { positional, flags };
}

function printCheckResult(result) {
  console.log();
  for (const line of result.output.split('\n')) {
    if (line.startsWith('✔')) console.log(c.green(line));
    else if (line.startsWith('✘')) console.log(c.red(line));
    else console.log(line);
  }
  console.log();
  if (result.passed) {
    console.log(c.bold(c.green('🎉 통과! 기록을 저장했어요.')));
    if (result.progress?.nextReviewAt) {
      console.log(c.dim(`   다음 복습 예정: ${new Date(result.progress.nextReviewAt).toLocaleDateString('ko-KR')}`));
    }
    if (result.history.length) {
      console.log(c.bold('\n내가 입력한 명령어'));
      for (const h of result.history.slice(-30)) console.log(`  ${c.dim('$')} ${h.cmd}`);
    }
    console.log(c.dim('\n해설과 다른 풀이 방법: lab solution   ·   끝내기: lab stop'));
  } else {
    console.log(c.yellow('아직 목표를 다 채우지 못했어요. 다시 들어가려면: lab shell   ·   힌트: lab hint'));
  }
}

async function cmdList(catalog, envFilter) {
  const progress = loadProgress();
  let running = [];
  try {
    running = await runningScenarioIds();
  } catch {
    /* Docker가 꺼져 있어도 목록은 보여준다 */
  }
  for (const env of catalog.envs) {
    if (envFilter && env.id !== envFilter) continue;
    const list = catalog.scenarios.filter((s) => s.env === env.id);
    if (!list.length) continue;
    console.log(`\n${c.bold(c.cyan(env.name))} ${c.dim(`(${env.id})`)}`);
    for (const s of list) {
      const st = scenarioStatus(progress, s.id);
      const lv = '★'.repeat(s.level) + '☆'.repeat(Math.max(0, 3 - s.level));
      const run = running.includes(s.id) ? c.green(' [실행 중]') : '';
      console.log(`  ${STATE_LABEL[st.state]}${s.id.padEnd(28)} ${c.yellow(lv)}  ${s.title}${run}`);
    }
  }
  console.log(c.dim(`\n  ${STATE_LABEL.done}통과  ${STATE_LABEL.review}복습할 때  ${STATE_LABEL.tried}시도함  ${STATE_LABEL.new}새 문제\n`));
}

async function cmdStart(catalog, query, { attach = true } = {}) {
  const scenario = await resolveScenario(catalog, query);
  console.log(c.dim(`\n▶ ${scenario.id} 준비 중...`));
  await startScenario(catalog, scenario, { onLog: (l) => console.log(c.dim(`  ${l}`)) });
  const docs = readScenarioDocs(scenario);
  console.log(`\n${renderMarkdown(docs.task)}\n`);
  if (!attach) return;
  await enterShell(catalog, scenario, { autoCheck: true });
}

async function enterShell(catalog, scenario, { autoCheck }) {
  if (!process.stdin.isTTY) {
    throw new Error('대화형 터미널에서 실행해야 합니다. (웹 UI를 쓰려면 lab web)');
  }
  setCurrent(scenario.id);
  console.log(c.dim('── 실습 셸에 접속합니다. 다 했으면 exit 로 나오세요 (자동 채점) ──'));
  await attachShellInteractive(containerName(scenario.id), envFor(catalog, scenario));
  if (autoCheck) {
    console.log(c.dim('\n── 셸에서 나왔어요. 채점합니다 ──'));
    printCheckResult(await checkScenario(catalog, scenario));
  }
}

async function cmdStatus(catalog) {
  const progress = loadProgress();
  console.log();
  for (const env of catalog.envs) {
    const list = catalog.scenarios.filter((s) => s.env === env.id);
    if (!list.length) continue;
    const done = list.filter((s) => ['done', 'review'].includes(scenarioStatus(progress, s.id).state)).length;
    const width = 20;
    const fill = Math.round((done / list.length) * width);
    console.log(`${env.name.padEnd(16)} ${c.green('█'.repeat(fill))}${c.dim('░'.repeat(width - fill))} ${done}/${list.length}`);
  }
  await cmdReview(catalog);
}

async function cmdReview(catalog) {
  const progress = loadProgress();
  const due = catalog.scenarios.filter((s) => scenarioStatus(progress, s.id).state === 'review');
  const next = catalog.scenarios.find((s) => ['new', 'tried'].includes(scenarioStatus(progress, s.id).state));
  console.log();
  if (due.length) {
    console.log(c.bold(c.magenta('↻ 지금 복습하면 좋은 시나리오')));
    for (const s of due) console.log(`  lab start ${s.id}   ${c.dim(s.title)}`);
  } else {
    console.log(c.dim('복습할 시나리오가 없어요.'));
  }
  if (next) console.log(`\n${c.bold('다음 추천')}: lab start ${next.id}   ${c.dim(next.title)}`);
  console.log();
}

async function main() {
  const [cmd, ...rest] = process.argv.slice(2);
  const { positional, flags } = parseArgs(rest);
  const catalog = loadCatalog();
  if (loadErrors.length && cmd !== 'validate') {
    loadErrors.forEach((e) => console.error(c.yellow(`⚠ 읽기 실패로 건너뜀: ${e}`)));
  }

  switch (cmd) {
    case undefined:
    case 'help':
    case '--help':
    case '-h':
      console.log(HELP);
      return;
    case 'list':
    case 'ls':
      return cmdList(catalog, positional[0]);
    case 'envs': {
      for (const env of catalog.envs) {
        let status = '';
        try {
          status = { ready: c.green('준비됨'), missing: c.dim('미빌드'), outdated: c.yellow('재빌드 필요') }[await imageStatus(env)];
        } catch {
          status = c.dim('Docker 연결 안 됨');
        }
        const count = catalog.scenarios.filter((s) => s.env === env.id).length;
        console.log(`${c.bold(env.id.padEnd(10))} ${env.name} ${c.dim(`· 시나리오 ${count}개 ·`)} ${status}\n  ${c.dim(env.description)}`);
      }
      return;
    }
    case 'start':
      return cmdStart(catalog, positional[0], { attach: !flags['no-shell'] });
    case 'reset': {
      const scenario = await resolveScenario(catalog, positional[0]);
      await startScenario(catalog, scenario, { onLog: (l) => console.log(c.dim(`  ${l}`)) });
      console.log(c.green(`↺ ${scenario.id} 를 처음 상태로 되돌렸어요. 접속: lab shell`));
      return;
    }
    case 'shell': {
      const scenario = await resolveScenario(catalog, positional[0]);
      return enterShell(catalog, scenario, { autoCheck: !flags['no-check'] });
    }
    case 'check': {
      const scenario = await resolveScenario(catalog, positional[0]);
      printCheckResult(await checkScenario(catalog, scenario));
      return;
    }
    case 'task': {
      const scenario = await resolveScenario(catalog, positional[0]);
      console.log(`\n${renderMarkdown(readScenarioDocs(scenario).task)}\n`);
      return;
    }
    case 'hint': {
      // lab hint 2  /  lab hint linux/01 2
      const nArg = positional.find((p) => /^\d+$/.test(p));
      const query = positional.find((p) => !/^\d+$/.test(p));
      const scenario = await resolveScenario(catalog, query);
      const { hints } = readScenarioDocs(scenario);
      if (!hints.length) return console.log('이 시나리오에는 힌트가 없어요.');
      const n = Math.min(Math.max(Number(nArg ?? 1), 1), hints.length);
      console.log(`\n${c.yellow(`💡 힌트 ${n}/${hints.length}`)}\n${renderMarkdown(hints[n - 1])}\n`);
      if (n < hints.length) console.log(c.dim(`다음 힌트: lab hint ${n + 1}\n`));
      return;
    }
    case 'solution':
    case 'answer': {
      const scenario = await resolveScenario(catalog, positional[0]);
      const st = scenarioStatus(loadProgress(), scenario.id);
      if (st.passes === 0 && !flags.yes) {
        console.log(c.yellow('아직 통과하지 않았어요. 해설을 먼저 보면 기억에 덜 남아요.'));
        console.log(c.dim('그래도 보려면: lab solution --yes  (힌트부터: lab hint)'));
        return;
      }
      const { debrief } = readScenarioDocs(scenario);
      console.log(`\n${renderMarkdown(debrief || '해설이 아직 없어요.')}\n`);
      if (st.lastHistory?.length) {
        console.log(c.bold('지난번에 내가 입력한 명령어'));
        for (const h of st.lastHistory.slice(-30)) console.log(`  ${c.dim('$')} ${h.cmd}`);
        console.log();
      }
      return;
    }
    case 'stop': {
      if (flags.all) {
        await ensureDockerReachable();
        const list = await listLabContainers();
        for (const ct of list) await removeContainer(ct.name);
        console.log(`실습 ${list.length}개를 종료했어요.`);
        return;
      }
      const scenario = await resolveScenario(catalog, positional[0]);
      const removed = await stopScenario(scenario);
      console.log(removed ? `■ ${scenario.id} 실습을 종료했어요.` : '실행 중인 실습이 없어요.');
      return;
    }
    case 'status':
      return cmdStatus(catalog);
    case 'review':
      return cmdReview(catalog);
    case 'build': {
      await ensureDockerReachable();
      const targets = flags.all || !positional[0] ? catalog.envs : catalog.envs.filter((e) => e.id === positional[0]);
      if (!targets.length) throw new Error(`환경 '${positional[0]}'이(가) 없습니다. lab envs 로 확인하세요.`);
      for (const env of targets) {
        console.log(c.bold(`\n▶ ${env.id} 빌드 (${env.image})`));
        await buildImage(env, { noCache: Boolean(flags['no-cache']) });
      }
      return;
    }
    case 'web': {
      const { startServer } = await import('../src/server.js');
      await startServer({
        port: Number(flags.port ?? process.env.PORT ?? 4000),
        host: flags.host ?? '127.0.0.1',
        open: Boolean(flags.open),
      });
      return;
    }
    case 'validate': {
      const { envs, scenarios, problems } = validateCatalog();
      console.log(`환경 ${envs.length}개, 시나리오 ${scenarios.length}개`);
      if (problems.length) {
        problems.forEach((p) => console.log(c.red(`✘ ${p}`)));
        process.exitCode = 1;
      } else console.log(c.green('✔ 문제 없음'));
      return;
    }
    case 'test': {
      const q = positional[0];
      const targets = !q
        ? catalog.scenarios
        : catalog.envs.some((e) => e.id === q)
          ? catalog.scenarios.filter((s) => s.env === q)
          : [await resolveScenario(catalog, q)];
      let failed = 0;
      for (const s of targets) {
        process.stdout.write(`${s.id.padEnd(32)} `);
        try {
          const r = await testScenario(catalog, s);
          if (r.skipped) console.log(c.dim('건너뜀 (solution.sh/.ps1 없음)'));
          else if (r.ok) console.log(c.green('✔ 통과'));
          else {
            failed++;
            const why = !r.beforeFailed ? '풀기 전에도 채점이 통과함' : !r.solutionOk ? 'solution.sh 실패' : '풀이 후 채점 실패';
            console.log(c.red(`✘ ${why}`));
            if (flags.verbose || targets.length === 1) console.log(c.dim(r.output));
          }
        } catch (err) {
          failed++;
          console.log(c.red(`✘ ${err.message}`));
        }
      }
      if (failed) {
        console.log(c.red(`\n${failed}개 실패 (자세히: lab test <시나리오> 또는 --verbose)`));
        process.exitCode = 1;
      }
      return;
    }
    default:
      console.log(c.red(`알 수 없는 명령: ${cmd}`));
      console.log(HELP);
      process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error(c.red(`\n오류: ${err.message}`));
  process.exitCode = 1;
});
