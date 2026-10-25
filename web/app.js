/* global Terminal, FitAddon */
'use strict';

const $ = (sel) => document.querySelector(sel);
const esc = (s) =>
  String(s).replace(/[&<>"']/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch]);

const state = {
  catalog: null,
  current: null, // 현재 보고 있는 시나리오 상세
  hintsShown: {}, // 시나리오별로 펼친 힌트 수
  term: null,
  fit: null,
  ws: null,
  busy: false,
};

async function api(path, body) {
  const opts = body
    ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }
    : {};
  const res = await fetch(path, opts);
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || res.statusText);
  return data;
}

// ---------------- 목록 ----------------

const STATE_TEXT = { new: '새 문제', tried: '시도함', done: '통과', review: '복습할 때' };

async function loadCatalog() {
  state.catalog = await api('/api/catalog');
  renderList();
  renderSummary();
}

function renderList() {
  const { envs, scenarios, dockerOk } = state.catalog;
  $('#docker-warning').hidden = dockerOk;
  const html = envs
    .map((env) => {
      const list = scenarios.filter((s) => s.env === env.id);
      if (!list.length) return '';
      const done = list.filter((s) => ['done', 'review'].includes(s.status.state)).length;
      return `<div class="env-group">
        <h3 title="${esc(env.description)}">${esc(env.name)} <small>${done}/${list.length}</small></h3>
        ${list
          .map(
            (s) => `<button class="scenario-item${state.current?.id === s.id ? ' active' : ''}" data-id="${esc(s.id)}">
              <i class="dot ${s.status.state}" title="${STATE_TEXT[s.status.state]}"></i>
              <span>
                <span class="name">${esc(s.title)}${s.running ? '<span class="running">● 실행 중</span>' : ''}</span>
                <span class="meta">${'★'.repeat(s.level)}${'☆'.repeat(Math.max(0, 3 - s.level))} · ${esc(s.tags.slice(0, 3).join(', '))}</span>
              </span>
            </button>`,
          )
          .join('')}
      </div>`;
    })
    .join('');
  $('#scenario-list').innerHTML = html;
}

function renderSummary() {
  const list = state.catalog.scenarios;
  const done = list.filter((s) => ['done', 'review'].includes(s.status.state)).length;
  const due = list.filter((s) => s.status.state === 'review');
  $('#summary').innerHTML = `<span>통과 <b>${done}</b>/${list.length}</span><span>복습 대기 <b>${due.length}</b></span>`;
  const next = due[0] || list.find((s) => ['new', 'tried'].includes(s.status.state));
  $('#next-up').innerHTML = next
    ? `<button class="btn primary" data-id="${esc(next.id)}">${due.length ? '↻ 복습하기' : '▶ 다음 추천'}: ${esc(next.title)}</button>`
    : '<p>모든 시나리오를 통과했어요! 🎉</p>';
}

document.addEventListener('click', (e) => {
  const item = e.target.closest('[data-id]');
  if (item) {
    location.hash = item.dataset.id;
    $('#sidebar').classList.remove('open');
  }
});
$('#menu-btn').addEventListener('click', () => $('#sidebar').classList.toggle('open'));

// ---------------- 상세 ----------------

async function openScenario(id) {
  disconnectTerminal();
  if (!id) {
    state.current = null;
    $('#welcome').hidden = false;
    $('#detail').hidden = true;
    renderList();
    return;
  }
  let detail;
  try {
    detail = await api(`/api/scenario?id=${encodeURIComponent(id)}`);
  } catch (err) {
    alert(err.message);
    location.hash = '';
    return;
  }
  state.current = detail;
  $('#welcome').hidden = true;
  $('#detail').hidden = false;
  $('#d-crumbs').textContent = `${detail.id} · ${'★'.repeat(detail.level)}`;
  $('#d-title').textContent = detail.title;
  $('#task').innerHTML = detail.taskHtml;
  $('#result').hidden = true;
  $('#history').hidden = true;
  $('#debrief').hidden = true;
  renderHints();
  renderList();
  setRunning(detail.running);
  if (detail.running) connectTerminal();
  else showOverlay('시작 버튼을 누르면 실습 환경이 만들어집니다.', [{ label: '▶ 시작', primary: true, onClick: start }]);
}

function setRunning(running) {
  state.current.running = running;
  $('#btn-start').textContent = running ? '↺ 처음부터' : '▶ 시작';
  $('#btn-check').disabled = !running;
  $('#btn-stop').disabled = !running;
}

function renderHints() {
  const { id, hintsHtml } = state.current;
  const shown = state.hintsShown[id] || 0;
  $('#hints').innerHTML = hintsHtml
    .slice(0, shown)
    .map((h, i) => `<div class="hint"><div class="hint-label">💡 힌트 ${i + 1}/${hintsHtml.length}</div>${h}</div>`)
    .join('');
  const btn = $('#btn-hint');
  btn.disabled = !hintsHtml.length || shown >= hintsHtml.length;
  btn.textContent = hintsHtml.length ? `💡 힌트 ${shown}/${hintsHtml.length}` : '💡 힌트 없음';
}

$('#btn-hint').addEventListener('click', () => {
  const { id } = state.current;
  state.hintsShown[id] = (state.hintsShown[id] || 0) + 1;
  renderHints();
  $('#hints').lastElementChild?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
});

$('#btn-debrief').addEventListener('click', () => {
  const cur = state.current;
  if (!cur.debriefHtml) return alert('이 시나리오에는 해설이 없어요.');
  if (!$('#debrief').hidden) {
    $('#debrief').hidden = true;
    return;
  }
  if (cur.status.passes === 0 && !confirm('아직 통과하지 않았어요. 해설을 먼저 보면 기억에 덜 남아요.\n힌트를 먼저 보는 건 어때요?\n\n그래도 해설을 볼까요?')) return;
  $('#debrief').innerHTML = cur.debriefHtml;
  $('#debrief').hidden = false;
  $('#debrief').scrollIntoView({ behavior: 'smooth' });
});

// ---------------- 시작 / 채점 / 종료 ----------------

async function start() {
  if (state.busy) return;
  const cur = state.current;
  if (cur.running && !confirm('지금까지 한 작업이 사라지고 처음 상태로 돌아갑니다. 계속할까요?')) return;
  state.busy = true;
  disconnectTerminal();
  $('#btn-start').disabled = true;
  $('#result').hidden = true;
  const log = $('#build-log');
  log.textContent = '';
  showOverlay('실습 환경을 준비하는 중... (처음엔 환경 이미지 빌드로 몇 분 걸릴 수 있어요)', []);
  log.hidden = false;
  try {
    const res = await fetch('/api/start', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: cur.id }),
    });
    if (!res.ok) throw new Error((await res.json()).error);
    const reader = res.body.getReader();
    const decoder = new TextDecoder();
    let buf = '';
    let error = null;
    for (;;) {
      const { value, done } = await reader.read();
      if (done) break;
      buf += decoder.decode(value, { stream: true });
      const lines = buf.split('\n');
      buf = lines.pop();
      for (const line of lines.filter(Boolean)) {
        const msg = JSON.parse(line);
        if (msg.type === 'log') {
          log.textContent += `${msg.line}\n`;
          log.scrollTop = log.scrollHeight;
        } else if (msg.type === 'error') error = msg.message;
      }
    }
    if (error) throw new Error(error);
    if (state.current !== cur) return; // 그 사이 다른 시나리오로 이동함
    state.hintsShown[cur.id] = 0;
    renderHints();
    setRunning(true);
    log.hidden = true;
    connectTerminal();
    loadCatalog();
  } catch (err) {
    showOverlay(`시작하지 못했어요: ${err.message}`, [{ label: '다시 시도', primary: true, onClick: start }]);
  } finally {
    state.busy = false;
    $('#btn-start').disabled = false;
  }
}
$('#btn-start').addEventListener('click', start);

async function check() {
  const btn = $('#btn-check');
  btn.disabled = true;
  try {
    const r = await api('/api/check', { id: state.current.id });
    renderResult(r);
    if (r.passed) {
      state.current.status.passes = (state.current.status.passes || 0) + 1;
      loadCatalog();
    }
  } catch (err) {
    alert(err.message);
  } finally {
    btn.disabled = !state.current.running;
    state.term?.focus();
  }
}
$('#btn-check').addEventListener('click', check);

function renderResult(r) {
  const items = r.output
    .split('\n')
    .filter((l) => l.trim())
    .map((l) => {
      const cls = l.startsWith('✔') ? 'ok' : l.startsWith('✘') ? 'ng' : '';
      return `<li class="${cls}">${esc(l)}</li>`;
    })
    .join('');
  const next = r.progress?.nextReviewAt ? new Date(r.progress.nextReviewAt).toLocaleDateString('ko-KR') : null;
  const el = $('#result');
  el.className = `result ${r.passed ? 'pass' : 'fail'}`;
  el.innerHTML = `<h3>${r.passed ? '🎉 통과!' : '아직이에요'}</h3><ul>${items}</ul>
    <div class="sub">${r.passed ? `해설에서 다른 풀이도 확인해 보세요.${next ? ` 다음 복습: ${next}` : ''}` : '✘ 항목을 확인해 보세요. 막히면 힌트!'}</div>`;
  el.hidden = false;
  el.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

  const hist = $('#history');
  if (r.passed && r.history.length) {
    hist.innerHTML = `<h3>내가 입력한 명령어</h3><pre>${r.history
      .slice(-40)
      .map((h) => `$ ${esc(h.cmd)}`)
      .join('\n')}</pre>`;
    hist.hidden = false;
  }
}

$('#btn-stop').addEventListener('click', async () => {
  if (!confirm('실습 환경을 종료할까요? (기록은 남아요)')) return;
  disconnectTerminal();
  await api('/api/stop', { id: state.current.id }).catch((err) => alert(err.message));
  setRunning(false);
  showOverlay('실습을 종료했어요.', [{ label: '▶ 다시 시작', primary: true, onClick: start }]);
  loadCatalog();
});

// ---------------- 터미널 ----------------

function showOverlay(msg, actions) {
  $('#overlay').hidden = false;
  $('#overlay-msg').textContent = msg;
  const box = $('#overlay-actions');
  box.innerHTML = '';
  for (const a of actions) {
    const b = document.createElement('button');
    b.className = `btn${a.primary ? ' primary' : ''}`;
    b.textContent = a.label;
    b.addEventListener('click', a.onClick);
    box.appendChild(b);
  }
  if (!msg.startsWith('실습 환경을 준비')) $('#build-log').hidden = true;
}

function disconnectTerminal() {
  if (state.ws) {
    state.ws.onclose = null;
    state.ws.close();
    state.ws = null;
  }
  if (state.term) {
    state.term.dispose();
    state.term = null;
  }
}

function connectTerminal() {
  disconnectTerminal();
  const dark = matchMedia('(prefers-color-scheme: dark)').matches;
  const term = new Terminal({
    cursorBlink: true,
    fontSize: 14,
    fontFamily: getComputedStyle(document.documentElement).getPropertyValue('--mono'),
    scrollback: 5000,
    theme: { background: '#10141b', foreground: dark ? '#e3e8ef' : '#e6e9ef', cursor: '#5b8cff', selectionBackground: '#33415588' },
  });
  const fit = new FitAddon.FitAddon();
  term.loadAddon(fit);
  term.open($('#term'));
  fit.fit();
  state.term = term;
  state.fit = fit;

  const id = state.current.id;
  const proto = location.protocol === 'https:' ? 'wss' : 'ws';
  const ws = new WebSocket(
    `${proto}://${location.host}/ws/terminal?id=${encodeURIComponent(id)}&cols=${term.cols}&rows=${term.rows}`,
  );
  ws.binaryType = 'arraybuffer';
  state.ws = ws;
  ws.onopen = () => {
    $('#overlay').hidden = true;
    term.focus();
  };
  ws.onmessage = (ev) => term.write(typeof ev.data === 'string' ? ev.data : new Uint8Array(ev.data));
  ws.onclose = (ev) => {
    if (state.ws !== ws) return;
    state.ws = null;
    const exited = ev.code === 1000;
    showOverlay(exited ? '셸에서 나왔어요.' : `터미널 연결이 끊겼어요. ${ev.reason || ''}`, [
      { label: '다시 접속', primary: true, onClick: connectTerminal },
      { label: '✓ 채점', onClick: check },
    ]);
  };
  term.onData((d) => ws.readyState === WebSocket.OPEN && ws.send(JSON.stringify({ t: 'i', d })));
  term.onResize(({ cols, rows }) => ws.readyState === WebSocket.OPEN && ws.send(JSON.stringify({ t: 'r', cols, rows })));
}

new ResizeObserver(() => {
  if (state.term && state.fit) {
    try {
      state.fit.fit();
    } catch {
      /* 숨겨진 상태에서는 무시 */
    }
  }
}).observe($('#term'));

// ---------------- 시작 ----------------

window.addEventListener('hashchange', () => openScenario(decodeURIComponent(location.hash.slice(1))));
loadCatalog()
  .then(() => openScenario(decodeURIComponent(location.hash.slice(1))))
  .catch((err) => {
    $('#scenario-list').innerHTML = `<p class="docker-warning">목록을 불러오지 못했어요: ${esc(err.message)}</p>`;
  });
