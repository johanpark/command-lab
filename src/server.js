// 웹 UI 서버: 시나리오 목록/문제/채점 API + 브라우저 터미널(WebSocket ↔ docker exec TTY)
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { marked } from 'marked';
import { WebSocketServer } from 'ws';
import { ROOT, findScenario, loadCatalog, readScenarioDocs } from './catalog.js';
import { containerName, findContainer, openShell } from './docker.js';
import { loadProgress, scenarioStatus } from './progress.js';
import { checkScenario, envFor, runningScenarioIds, startScenario, stopScenario } from './session.js';

const WEB_DIR = path.join(ROOT, 'web');
const MODULES = path.join(ROOT, 'node_modules');
const STATIC = {
  '/': [path.join(WEB_DIR, 'index.html'), 'text/html'],
  '/app.js': [path.join(WEB_DIR, 'app.js'), 'text/javascript'],
  '/style.css': [path.join(WEB_DIR, 'style.css'), 'text/css'],
  '/vendor/xterm.js': [path.join(MODULES, '@xterm/xterm/lib/xterm.js'), 'text/javascript'],
  '/vendor/xterm.css': [path.join(MODULES, '@xterm/xterm/css/xterm.css'), 'text/css'],
  '/vendor/addon-fit.js': [path.join(MODULES, '@xterm/addon-fit/lib/addon-fit.js'), 'text/javascript'],
};

// 다른 사이트가 브라우저를 통해 이 서버(=Docker 제어)를 건드리지 못하게 같은 출처만 허용한다.
function sameOrigin(req) {
  const origin = req.headers.origin;
  if (!origin) return true;
  try {
    return new URL(origin).host === req.headers.host;
  } catch {
    return false;
  }
}

function sendJson(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
  res.end(JSON.stringify(body));
}

async function readJson(req) {
  if (!String(req.headers['content-type']).startsWith('application/json')) {
    throw Object.assign(new Error('Content-Type 은 application/json 이어야 합니다.'), { status: 415 });
  }
  let raw = '';
  for await (const chunk of req) {
    raw += chunk;
    if (raw.length > 64 * 1024) throw Object.assign(new Error('요청이 너무 큽니다.'), { status: 413 });
  }
  return raw ? JSON.parse(raw) : {};
}

function lookup(catalog, id) {
  const { scenario, error } = findScenario(catalog.scenarios, id);
  if (!scenario || scenario.id !== id) throw Object.assign(new Error(error ?? `없는 시나리오: ${id}`), { status: 404 });
  return scenario;
}

async function safeRunning() {
  try {
    return { running: await runningScenarioIds(), dockerOk: true };
  } catch {
    return { running: [], dockerOk: false };
  }
}

const starting = new Set();

const routes = {
  'GET /api/catalog': async () => {
    const catalog = loadCatalog();
    const progress = loadProgress();
    const { running, dockerOk } = await safeRunning();
    return {
      dockerOk,
      envs: catalog.envs.map(({ id, name, description }) => ({ id, name, description })),
      scenarios: catalog.scenarios.map((s) => {
        const { lastHistory, ...status } = scenarioStatus(progress, s.id);
        return {
          id: s.id,
          title: s.title,
          env: s.env,
          level: s.level,
          minutes: s.minutes,
          tags: s.tags,
          summary: s.summary,
          status,
          running: running.includes(s.id),
        };
      }),
    };
  },

  'GET /api/scenario': async (req, url) => {
    const catalog = loadCatalog();
    const scenario = lookup(catalog, url.searchParams.get('id'));
    const docs = readScenarioDocs(scenario);
    const status = scenarioStatus(loadProgress(), scenario.id);
    const { running } = await safeRunning();
    return {
      id: scenario.id,
      title: scenario.title,
      env: scenario.env,
      level: scenario.level,
      tags: scenario.tags,
      taskHtml: marked.parse(docs.task),
      hintsHtml: docs.hints.map((h) => marked.parse(h)),
      debriefHtml: docs.debrief ? marked.parse(docs.debrief) : '',
      status,
      running: running.includes(scenario.id),
    };
  },

  // 이미지 빌드가 몇 분 걸릴 수 있어 진행 로그를 NDJSON 으로 흘려보낸다.
  'POST /api/start': async (req, url, res) => {
    const { id } = await readJson(req);
    const catalog = loadCatalog();
    const scenario = lookup(catalog, id);
    if (starting.has(id)) throw Object.assign(new Error('이미 준비 중입니다.'), { status: 409 });
    starting.add(id);
    res.writeHead(200, { 'Content-Type': 'application/x-ndjson; charset=utf-8', 'Cache-Control': 'no-store' });
    const send = (obj) => res.write(`${JSON.stringify(obj)}\n`);
    try {
      await startScenario(catalog, scenario, { onLog: (line) => send({ type: 'log', line }) });
      send({ type: 'done' });
    } catch (err) {
      send({ type: 'error', message: err.message });
    } finally {
      starting.delete(id);
      res.end();
    }
    return undefined;
  },

  'POST /api/check': async (req) => {
    const { id } = await readJson(req);
    const catalog = loadCatalog();
    const result = await checkScenario(catalog, lookup(catalog, id));
    return { passed: result.passed, output: result.output, history: result.history, progress: result.progress };
  },

  'POST /api/stop': async (req) => {
    const { id } = await readJson(req);
    const catalog = loadCatalog();
    return { stopped: await stopScenario(lookup(catalog, id)) };
  },
};

async function handle(req, res) {
  const url = new URL(req.url, 'http://localhost');
  const key = `${req.method} ${url.pathname}`;

  if (routes[key]) {
    if (!sameOrigin(req)) return sendJson(res, 403, { error: '허용되지 않은 출처' });
    try {
      const body = await routes[key](req, url, res);
      if (body !== undefined) sendJson(res, 200, body);
    } catch (err) {
      if (res.headersSent) return res.end();
      sendJson(res, err.status ?? 500, { error: err.message });
    }
    return;
  }

  const file = req.method === 'GET' && STATIC[url.pathname];
  if (file) {
    fs.readFile(file[0], (err, data) => {
      if (err) return sendJson(res, 500, { error: `파일을 읽을 수 없습니다: ${file[0]}` });
      res.writeHead(200, { 'Content-Type': `${file[1]}; charset=utf-8`, 'Cache-Control': 'no-cache' });
      res.end(data);
    });
    return;
  }
  sendJson(res, 404, { error: 'Not found' });
}

// 브라우저 xterm.js ↔ 컨테이너 셸
// 클라이언트 → 서버: {"t":"i","d":"입력"} / {"t":"r","cols":80,"rows":24}
// 서버 → 클라이언트: 셸 출력(바이너리)
async function handleTerminal(ws, url) {
  const catalog = loadCatalog();
  let shell;
  try {
    const scenario = lookup(catalog, url.searchParams.get('id'));
    const env = envFor(catalog, scenario);
    const found = await findContainer(containerName(scenario.id));
    if (!found?.info.State.Running) throw new Error('실습이 실행 중이 아닙니다.');
    const cols = Number(url.searchParams.get('cols')) || 80;
    const rows = Number(url.searchParams.get('rows')) || 24;
    shell = await openShell(found.container, env, { cols, rows });
  } catch (err) {
    ws.close(4000, err.message.slice(0, 120));
    return;
  }
  const { exec, stream, close } = shell;
  stream.on('data', (chunk) => ws.readyState === ws.OPEN && ws.send(chunk));
  stream.on('end', () => ws.close(1000, 'exit'));
  stream.on('error', () => ws.close(1011, 'stream error'));
  ws.on('message', (raw) => {
    let msg;
    try {
      msg = JSON.parse(raw.toString());
    } catch {
      return;
    }
    if (msg.t === 'i' && typeof msg.d === 'string') stream.write(msg.d);
    else if (msg.t === 'r') exec.resize({ h: msg.rows, w: msg.cols }).catch(() => {});
  });
  ws.on('close', () => {
    stream.end();
    close();
  });
}

function openBrowser(url) {
  const cmd = process.platform === 'darwin' ? 'open' : process.platform === 'win32' ? 'cmd' : 'xdg-open';
  const args = process.platform === 'win32' ? ['/c', 'start', '', url] : [url];
  spawn(cmd, args, { stdio: 'ignore', detached: true }).on('error', () => {}).unref();
}

export function startServer({ port = 4000, host = '127.0.0.1', open = false } = {}) {
  const server = http.createServer((req, res) => {
    handle(req, res).catch((err) => sendJson(res, 500, { error: err.message }));
  });
  const wss = new WebSocketServer({ noServer: true });
  server.on('upgrade', (req, socket, head) => {
    const url = new URL(req.url, 'http://localhost');
    if (url.pathname !== '/ws/terminal' || !sameOrigin(req)) {
      socket.destroy();
      return;
    }
    wss.handleUpgrade(req, socket, head, (ws) => handleTerminal(ws, url));
  });
  return new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(port, host, () => {
      const url = `http://${host === '0.0.0.0' ? 'localhost' : host}:${port}`;
      console.log(`\ncommand-lab 웹 UI: ${url}\n종료하려면 Ctrl+C\n`);
      if (open) openBrowser(url);
      resolve(server);
    });
  });
}
