// Docker 연동: 환경 이미지 빌드, 실습 컨테이너 생성/삭제, 컨테이너 안 명령 실행.
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { PassThrough } from 'node:stream';
import Docker from 'dockerode';
import tar from 'tar-fs';
import { LIB_DIR } from './catalog.js';

export const LAB_ROOT = '/opt/cmdlab';

function dockerOptions() {
  if (process.env.DOCKER_HOST) return undefined; // docker-modem이 DOCKER_HOST를 직접 읽는다
  if (process.platform === 'win32') return { socketPath: '//./pipe/docker_engine' };
  const home = os.homedir();
  const candidates = [
    '/var/run/docker.sock',
    path.join(home, '.docker/run/docker.sock'), // Docker Desktop (macOS)
    path.join(home, '.orbstack/run/docker.sock'),
    path.join(home, '.colima/default/docker.sock'),
    path.join(home, '.rd/docker.sock'), // Rancher Desktop
  ];
  const found = candidates.find((p) => fs.existsSync(p));
  return found ? { socketPath: found } : undefined;
}

let client;
export function docker() {
  client ??= new Docker(dockerOptions());
  return client;
}

export async function ensureDockerReachable() {
  try {
    await docker().ping();
  } catch (err) {
    throw new Error(
      `Docker에 연결할 수 없습니다. Docker Desktop이 실행 중인지 확인하세요. (${err.code ?? err.message})`,
    );
  }
}

export function containerName(scenarioId) {
  return `cmdlab-${scenarioId.replace(/[^a-zA-Z0-9_.-]+/g, '-')}`;
}

// ---------- 이미지 ----------

// 환경 디렉터리 내용이 바뀌면 이미지를 다시 빌드하도록 해시를 라벨로 남긴다.
// env.yaml 은 빌드에 쓰이지 않는 메타데이터(이름, 카테고리 등)라서 제외한다.
const NOT_BUILD_INPUT = new Set(['env.yaml']);

export function hashDir(dir) {
  const h = crypto.createHash('sha256');
  const walk = (d) => {
    for (const entry of fs.readdirSync(d, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const p = path.join(d, entry.name);
      if (entry.isDirectory()) walk(p);
      else if (!(d === dir && NOT_BUILD_INPUT.has(entry.name))) {
        h.update(path.relative(dir, p).replaceAll('\\', '/'));
        h.update(fs.readFileSync(p, 'utf8').replaceAll('\r\n', '\n'));
      }
    }
  };
  walk(dir);
  return h.digest('hex').slice(0, 16);
}

export async function imageStatus(env) {
  try {
    const info = await docker().getImage(env.image).inspect();
    const built = info.Config?.Labels?.['cmdlab.hash'];
    return built === hashDir(env.dir) ? 'ready' : 'outdated';
  } catch (err) {
    if (err.statusCode === 404) return 'missing';
    throw err;
  }
}

// docker CLI로 빌드한다 (진행 상황 출력이 가장 읽기 좋음).
// onLog가 없으면 터미널에 그대로 출력한다.
export function buildImage(env, { onLog, noCache = false } = {}) {
  const args = ['build', '-t', env.image, '--label', `cmdlab.hash=${hashDir(env.dir)}`, '--label', 'cmdlab=1'];
  if (noCache) args.push('--no-cache');
  if (onLog) args.push('--progress=plain');
  args.push(env.dir);
  return new Promise((resolve, reject) => {
    const child = spawn('docker', args, { stdio: onLog ? ['ignore', 'pipe', 'pipe'] : 'inherit' });
    if (onLog) {
      let buf = '';
      const onData = (chunk) => {
        buf += chunk.toString();
        const lines = buf.split(/\r?\n/);
        buf = lines.pop();
        lines.forEach((l) => l && onLog(l));
      };
      child.stdout.on('data', onData);
      child.stderr.on('data', onData);
    }
    child.on('error', (err) =>
      reject(new Error(`docker 명령을 실행할 수 없습니다. Docker가 설치되어 있나요? (${err.message})`)),
    );
    child.on('close', (code) =>
      code === 0 ? resolve() : reject(new Error(`이미지 빌드 실패 (${env.image}, exit ${code})`)),
    );
  });
}

export async function ensureImage(env, opts = {}) {
  const status = await imageStatus(env);
  if (status === 'ready') return false;
  opts.onLog?.(status === 'missing' ? `[${env.id}] 환경 이미지를 처음 빌드합니다. 몇 분 걸릴 수 있어요...` : `[${env.id}] 환경 정의가 바뀌어 이미지를 다시 빌드합니다...`);
  await buildImage(env, opts);
  return true;
}

// ---------- 컨테이너 ----------

export async function findContainer(name) {
  try {
    const c = docker().getContainer(name);
    const info = await c.inspect();
    return { container: c, info };
  } catch (err) {
    if (err.statusCode === 404) return null;
    throw err;
  }
}

export async function removeContainer(name) {
  const found = await findContainer(name);
  if (found) await found.container.remove({ force: true, v: true });
  return Boolean(found);
}

export async function listLabContainers() {
  const list = await docker().listContainers({ all: true, filters: { label: ['cmdlab.scenario'] } });
  return list.map((c) => ({
    name: c.Names[0]?.replace(/^\//, ''),
    scenarioId: c.Labels['cmdlab.scenario'],
    running: c.State === 'running',
    created: c.Created,
  }));
}

async function packDir(dir, { exclude = [] } = {}) {
  const chunks = [];
  const stream = tar.pack(dir, {
    // traps/ 같은 작성자용 파일은 컨테이너에 넣지 않는다 (학습자가 오답 목록을 볼 수 있으므로)
    ignore: (name) => exclude.some((x) => path.relative(dir, name).split(path.sep)[0] === x),
    map: (header) => ({ ...header, uid: 0, gid: 0, uname: 'root', gname: 'root' }),
  });
  for await (const chunk of stream) chunks.push(chunk);
  return Buffer.concat(chunks);
}

export async function createLabContainer({ scenario, env }) {
  const name = containerName(scenario.id);
  await removeContainer(name);
  const container = await docker().createContainer({
    name,
    Image: env.image,
    Hostname: env.hostname,
    User: 'root',
    Cmd: env.command ?? ['sleep', 'infinity'],
    WorkingDir: env.workdir,
    Env: ['LANG=C.UTF-8', 'LC_ALL=C.UTF-8', 'TERM=xterm-256color'],
    Labels: { cmdlab: '1', 'cmdlab.scenario': scenario.id, 'cmdlab.env': env.id },
    // 익명 볼륨 (예: Docker-in-Docker 의 /var/lib/docker). 컨테이너를 지울 때 함께 지운다
    Volumes: Object.fromEntries((env.volumes ?? []).map((v) => [v, {}])),
    HostConfig: {
      Init: true,
      Memory: (env.memory ?? 768) * 1024 * 1024,
      NanoCpus: (env.cpus ?? 1) * 1_000_000_000,
      PidsLimit: env.pids ?? 512,
      // 컨테이너 안에서 dockerd 를 돌려야 하는 환경(docker)만 켠다
      Privileged: Boolean(env.privileged),
    },
  });
  await container.start();
  await execCapture(container, ['mkdir', '-p', `${LAB_ROOT}/lib`, `${LAB_ROOT}/scenario`]);
  await container.putArchive(await packDir(LIB_DIR), { path: `${LAB_ROOT}/lib` });
  await container.putArchive(await packDir(scenario.dir, { exclude: ['traps'] }), { path: `${LAB_ROOT}/scenario` });
  return container;
}

// 컨테이너 안에서 명령을 실행하고 출력/종료코드를 모은다.
export async function execCapture(container, cmd, { user = 'root', workdir = '/', env = [] } = {}) {
  const exec = await container.exec({
    Cmd: cmd,
    User: user,
    WorkingDir: workdir,
    Env: ['LANG=C.UTF-8', 'LC_ALL=C.UTF-8', ...env],
    AttachStdout: true,
    AttachStderr: true,
  });
  const stream = await exec.start({ hijack: true, stdin: false });
  const out = new PassThrough();
  const err = new PassThrough();
  const outChunks = [];
  const errChunks = [];
  out.on('data', (c) => outChunks.push(c));
  err.on('data', (c) => errChunks.push(c));
  container.modem.demuxStream(stream, out, err);
  await new Promise((resolve, reject) => {
    stream.on('end', resolve);
    stream.on('close', resolve);
    stream.on('error', reject);
  });
  let info = await exec.inspect();
  for (let i = 0; info.Running && i < 50; i++) {
    await new Promise((r) => setTimeout(r, 50));
    info = await exec.inspect();
  }
  return {
    exitCode: info.ExitCode,
    stdout: Buffer.concat(outChunks).toString('utf8'),
    stderr: Buffer.concat(errChunks).toString('utf8'),
  };
}

// 웹 터미널용 대화형 셸 (TTY)
// 브라우저 연결이 끊겨도 docker exec 셸은 스스로 끝나지 않으므로, PID를 기록해 두고 close()로 정리한다.
export async function openShell(container, env, { cols = 80, rows = 24 } = {}) {
  const pidFile = `${LAB_ROOT}/run/shell-${crypto.randomUUID()}.pid`;
  const exec = await container.exec({
    Cmd: ['sh', '-c', 'echo $$ > "$0"; exec "$@"', pidFile, ...env.shell],
    User: env.user,
    WorkingDir: env.workdir,
    Env: ['TERM=xterm-256color', 'LANG=C.UTF-8', 'LC_ALL=C.UTF-8', 'COLORTERM=truecolor'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    Tty: true,
  });
  const stream = await exec.start({ hijack: true, stdin: true, Tty: true });
  await exec.resize({ h: rows, w: cols }).catch(() => {});
  const close = () =>
    execCapture(container, [
      'sh',
      '-c',
      'pid=$(cat "$1" 2>/dev/null) && kill -HUP "$pid" 2>/dev/null && sleep 1 && kill -KILL "$pid" 2>/dev/null; rm -f "$1"',
      'sh',
      pidFile,
    ]).catch(() => {});
  return { exec, stream, close };
}

// CLI용: 현재 터미널을 컨테이너 셸에 그대로 연결한다.
export function attachShellInteractive(name, env) {
  const args = ['exec', '-it', '-u', env.user, '-w', env.workdir, '-e', 'LANG=C.UTF-8', '-e', 'LC_ALL=C.UTF-8', name, ...env.shell];
  return new Promise((resolve, reject) => {
    const child = spawn('docker', args, { stdio: 'inherit' });
    child.on('error', reject);
    child.on('close', (code) => resolve(code));
  });
}
