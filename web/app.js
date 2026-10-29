/* global Terminal, FitAddon */
'use strict';

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => [...document.querySelectorAll(sel)];
const esc = (s) =>
  String(s ?? '').replace(/[&<>"']/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch]);

// 브라우저 저장소는 막혀 있을 수 있으니 항상 조용히 실패하게
const store = {
  get(key, fallback) {
    try {
      const v = localStorage.getItem(`cmdlab.${key}`);
      return v === null ? fallback : JSON.parse(v);
    } catch {
      return fallback;
    }
  },
  set(key, value) {
    try {
      localStorage.setItem(`cmdlab.${key}`, JSON.stringify(value));
    } catch {
      /* 무시 */
    }
  },
};

const LEVEL_NAME = { 1: '입문', 2: '기초', 3: '실전' };
const STATE_NAME = { new: '새 문제', tried: '도전 중', done: '통과', review: '복습할 때' };
// 글꼴마다 모양이 달라지는 문자(✓ ↻ …) 대신 SVG 로 그린다
const svgIcon = (body) => `<svg viewBox="0 0 16 16" aria-hidden="true">${body}</svg>`;
const STATE_MARK = {
  new: '',
  tried: svgIcon('<path d="M8 3.5a4.5 4.5 0 0 1 0 9z" fill="currentColor"/>'),
  done: svgIcon('<path d="M4.4 8.3l2.4 2.4 4.8-5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'),
  review: svgIcon(
    '<path d="M11.9 8.6a4 4 0 1 1-1.3-3.6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>' +
      '<path d="M11.6 2.9v2.6H9" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>',
  ),
};
const isDone = (s) => s.status.state === 'done' || s.status.state === 'review';

const state = {
  catalog: null,
  order: [], // 사이드바에 보이는 순서 (환경 → 카테고리 → 시나리오)
  current: null, // 보고 있는 시나리오 상세
  query: '',
  env: store.get('env', null), // 사이드바에서 보고 있는 환경
  onlyTodo: store.get('onlyTodo', false),
  openCats: store.get('openCats', {}),
  results: {}, // 시나리오별 마지막 채점 결과 (이번 세션)
  debriefOpen: {},
  tab: 'task',
  term: null,
  fit: null,
  ws: null,
  busy: false,
  fontSize: store.get('fontSize', 14),
};

// ---------------- 공통 ----------------

async function api(path, body) {
  const opts = body
    ? { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }
    : {};
  const res = await fetch(path, opts);
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || res.statusText);
  return data;
}

function toast(msg, kind = 'info', ms = 3500) {
  const el = document.createElement('div');
  el.className = `toast ${kind}`;
  el.textContent = msg;
  el.title = '눌러서 닫기';
  el.addEventListener('click', () => el.remove());
  $('#toasts').appendChild(el);
  setTimeout(() => el.remove(), ms);
}

const levelDots = (lv) =>
  `<span class="lv l${lv}" title="난이도: ${LEVEL_NAME[lv] ?? lv}">${[1, 2, 3].map((i) => `<i class="${i <= lv ? 'on' : ''}"></i>`).join('')}</span>`;
const stateIcon = (st) => `<span class="st ${st}" title="${STATE_NAME[st]}">${STATE_MARK[st]}</span>`;
const fmtDate = (iso) => (iso ? new Date(iso).toLocaleDateString('ko-KR', { month: 'long', day: 'numeric' }) : '');
const envOf = (id) => state.catalog.envs.find((e) => e.id === id);
const catOf = (env, id) =>
  env?.categories.find((c) => c.id === id) ?? { id: 'etc', name: '기타', icon: '📌', description: '' };
const byId = (id) => state.catalog.scenarios.find((s) => s.id === id);

function progressBar(list) {
  const total = list.length || 1;
  const done = list.filter((s) => s.status.state === 'done').length;
  const review = list.filter((s) => s.status.state === 'review').length;
  return `<div class="bar" role="img" aria-label="${done + review}/${list.length} 통과"><i style="width:${(done / total) * 100}%"></i><i class="review" style="width:${(review / total) * 100}%"></i></div>`;
}

// 환경의 카테고리 순서대로 시나리오를 묶는다
function groupByCategory(env, list) {
  const groups = env.categories.map((c) => ({ cat: c, items: [] }));
  const etc = { cat: catOf(null, 'etc'), items: [] };
  for (const s of list) (groups.find((g) => g.cat.id === s.category) ?? etc).items.push(s);
  return [...groups, etc].filter((g) => g.items.length);
}

// ---------------- 카탈로그 ----------------

async function loadCatalog() {
  state.catalog = await api('/api/catalog');
  const { envs, scenarios } = state.catalog;
  state.order = envs.flatMap((env) =>
    groupByCategory(
      env,
      scenarios.filter((s) => s.env === env.id),
    ).flatMap((g) => g.items),
  );
  renderTree();
  renderTopStats();
  if (!state.current) renderHome();
}

const matchesQuery = (s, q) => [s.title, s.id, s.summary, ...s.tags].join(' ').toLowerCase().includes(q);

function highlight(text) {
  const q = state.query.trim();
  if (!q) return esc(text);
  const i = text.toLowerCase().indexOf(q.toLowerCase());
  if (i < 0) return esc(text);
  return `${esc(text.slice(0, i))}<mark>${esc(text.slice(i, i + q.length))}</mark>${esc(text.slice(i + q.length))}`;
}

// 카테고리 진행 상황: 시나리오마다 점 하나 (상태별 색)
const statusDots = (items) =>
  `<span class="dots" aria-label="${items.filter(isDone).length}/${items.length} 통과">${items
    .map((s) => `<i class="${s.status.state}" title="${esc(s.title)}"></i>`)
    .join('')}</span>`;

// 펼쳐 둔 카테고리 (환경별). 처음엔 지금 보는 문제나 안 푼 문제가 있는 첫 카테고리만 연다
function openCats(env) {
  if (!state.openCats[env.id]) {
    const groups = groupByCategory(env, state.catalog.scenarios.filter((s) => s.env === env.id));
    const first = groups.find((g) => g.items.some((s) => !isDone(s))) ?? groups[0];
    state.openCats[env.id] = first ? [first.cat.id] : [];
  }
  return new Set(state.openCats[env.id]);
}
function setCatOpen(envId, catId, open) {
  const set = new Set(state.openCats[envId] ?? []);
  if (open) set.add(catId);
  else set.delete(catId);
  state.openCats[envId] = [...set];
  store.set('openCats', state.openCats);
}

function renderTree() {
  const { envs, scenarios, dockerOk } = state.catalog;
  $('#docker-warning').hidden = dockerOk;
  if (!envs.some((e) => e.id === state.env)) state.env = envs[0]?.id;

  // 환경 탭
  $('#env-tabs').innerHTML = envs
    .map((env) => {
      const all = scenarios.filter((s) => s.env === env.id);
      const n = all.filter(isDone).length;
      const sel = env.id === state.env && !state.query.trim();
      return `<button role="tab" class="env-tab${sel ? ' active' : ''}" data-env="${esc(env.id)}" aria-selected="${sel}" title="${esc(env.name)} · ${n}/${all.length} 통과">
        <span class="env-tab-icon">${env.icon}</span>
        <span class="env-tab-name">${esc(env.short ?? env.name)}</span>
        <span class="env-tab-bar"><i style="width:${(n / (all.length || 1)) * 100}%"></i></span>
      </button>`;
    })
    .join('');

  const q = state.query.trim().toLowerCase();
  if (q) {
    // 검색: 모든 환경에서 찾아 평평한 목록으로
    // 제목 > 태그(명령어) > 설명·ID 순으로 더 잘 맞는 것을 위에
    const score = (s) =>
      s.title.toLowerCase().includes(q) ? 0 : s.tags.some((t) => t.toLowerCase().includes(q)) ? 1 : 2;
    const found = state.order.filter((s) => matchesQuery(s, q)).sort((a, b) => score(a) - score(b));
    $('#tree').innerHTML = `<div class="tree-head"><span>검색 결과 <b>${found.length}</b>개</span></div>
      ${found.length ? `<div class="search-list">${found.map((s) => itemHtml(s, true)).join('')}</div>` : '<p class="empty">일치하는 시나리오가 없어요.<br><span class="muted">명령어 이름(grep, chmod…)으로도 찾을 수 있어요.</span></p>'}`;
    return;
  }

  const env = envOf(state.env);
  const all = scenarios.filter((s) => s.env === env.id);
  const open = openCats(env);
  const groups = groupByCategory(env, all);
  const body = groups
    .map(({ cat, items }) => {
      const shown = state.onlyTodo ? items.filter((s) => !isDone(s)) : items;
      const isOpen = open.has(cat.id) || items.some((s) => s.id === state.current?.id);
      const allDone = items.every(isDone);
      return `<section class="cat${isOpen ? ' open' : ''}${allDone ? ' complete' : ''}">
        <button class="cat-head" data-cat="${esc(cat.id)}" aria-expanded="${isOpen}" title="${esc(cat.description)}">
          <span class="chev" aria-hidden="true">›</span>
          <span class="cat-icon">${cat.icon}</span>
          <span class="cat-name">${esc(cat.name)}</span>
          ${statusDots(items)}
        </button>
        <div class="cat-body">${
          shown.length
            ? shown.map((s) => itemHtml(s)).join('')
            : '<p class="cat-empty">✓ 모두 통과했어요</p>'
        }</div>
      </section>`;
    })
    .join('');
  const done = all.filter(isDone).length;
  $('#tree').innerHTML = `<div class="tree-head">
      <span class="tree-title">${esc(env.name)} <span class="muted">${done}/${all.length}</span></span>
      <button class="toggle${state.onlyTodo ? ' on' : ''}" id="only-todo" aria-pressed="${state.onlyTodo}" title="통과한 문제 숨기기">
        <i></i>남은 문제만
      </button>
    </div>
    <p class="env-desc">${esc(env.description)}</p>
    ${body}`;
}

function itemHtml(s, withEnv = false) {
  const active = state.current?.id === s.id;
  const env = withEnv ? envOf(s.env) : null;
  return `<a class="item${active ? ' active' : ''}" href="#${esc(s.id)}" ${active ? 'aria-current="page"' : ''} title="${esc(s.title)} · ${LEVEL_NAME[s.level] ?? ''} · ${s.minutes}분">
    ${stateIcon(s.status.state)}
    <span class="item-title">${highlight(s.title)}${
      env ? `<span class="item-sub">${env.icon} ${esc(env.short ?? env.name)} › ${esc(catOf(env, s.category).name)}</span>` : ''
    }</span>
    ${s.running ? '<span class="live" title="실행 중"></span>' : ''}
  </a>`;
}

function renderTopStats() {
  const list = state.catalog.scenarios;
  const done = list.filter(isDone).length;
  const due = list.filter((s) => s.status.state === 'review').length;
  $('#top-stats').innerHTML = `
    ${progressBar(list)}
    <span>통과 <b>${done}</b>/${list.length}</span>
    <span class="hide-sm">복습 대기 <b>${due}</b></span>`;
}

$('#env-tabs').addEventListener('click', (e) => {
  const tab = e.target.closest('[data-env]');
  if (!tab) return;
  state.env = tab.dataset.env;
  store.set('env', state.env);
  if (state.query) {
    state.query = '';
    $('#search').value = '';
  }
  renderTree();
  $('#tree').scrollTop = 0;
});

$('#tree').addEventListener('click', (e) => {
  const head = e.target.closest('[data-cat]');
  if (head) {
    const sec = head.closest('.cat');
    const open = !sec.classList.contains('open');
    sec.classList.toggle('open', open);
    head.setAttribute('aria-expanded', String(open));
    setCatOpen(state.env, head.dataset.cat, open);
    return;
  }
  if (e.target.closest('#only-todo')) {
    state.onlyTodo = !state.onlyTodo;
    store.set('onlyTodo', state.onlyTodo);
    renderTree();
    return;
  }
  if (e.target.closest('.item')) closeSidebar();
});

$('#search').addEventListener('input', (e) => {
  state.query = e.target.value;
  renderTree();
});
$('#search').addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    e.target.value = '';
    state.query = '';
    renderTree();
    e.target.blur();
  }
  if (e.key === 'Enter') $('.tree .item')?.click();
});

function openSidebar() {
  $('#sidebar').classList.add('open');
  $('#scrim').hidden = false;
  $('#menu-btn').setAttribute('aria-expanded', 'true');
}
function closeSidebar() {
  $('#sidebar').classList.remove('open');
  $('#scrim').hidden = true;
  $('#menu-btn').setAttribute('aria-expanded', 'false');
}
$('#menu-btn').addEventListener('click', () => ($('#sidebar').classList.contains('open') ? closeSidebar() : openSidebar()));
$('#scrim').addEventListener('click', closeSidebar);

// ---------------- 홈 ----------------

// 이어서 할 문제: 하던 문제 → 복습할 문제 → 순서상 첫 안 푼 문제
function pickNext() {
  const cur = state.catalog.current && byId(state.catalog.current);
  if (cur && !isDone(cur)) return { s: cur, why: '이어서 하기' };
  const review = state.order.find((s) => s.status.state === 'review');
  if (review) return { s: review, why: '복습할 시간이에요' };
  const next = state.order.find((s) => !isDone(s));
  if (next) return { s: next, why: cur ? '다음 추천' : '여기서 시작하세요' };
  return null;
}

function renderHome() {
  const { envs, scenarios } = state.catalog;
  const next = pickNext();
  const done = scenarios.filter(isDone).length;
  const due = state.order.filter((s) => s.status.state === 'review');
  const nextEnv = next && envOf(next.s.env);
  const nextCat = next && catOf(nextEnv, next.s.category);

  $('#home').innerHTML = `<div class="home-inner">
    <div class="hello">
      <h1>상황 속에서 명령어를 익혀요</h1>
      <p>진짜 컨테이너에 문제 상황이 만들어지고, 직접 해결하면 결과로 채점해요. 정답 명령어는 하나가 아니에요.</p>
    </div>

    <div class="hero-grid">
      ${
        next
          ? `<div class="card continue">
              <span class="eyebrow">${esc(next.why)}</span>
              <div class="crumbs">${nextEnv.icon} ${esc(nextEnv.name)} <span class="sep">›</span> ${nextCat.icon} ${esc(nextCat.name)}</div>
              <h3>${esc(next.s.title)}</h3>
              <p>${esc(next.s.summary)}</p>
              <div class="meta">${levelDots(next.s.level)} ${LEVEL_NAME[next.s.level]} <span class="dot">·</span> ⏱ ${next.s.minutes}분
                ${next.s.tags.slice(0, 4).map((t) => `<span class="tag">${esc(t)}</span>`).join('')}</div>
              <a class="btn primary big" href="#${esc(next.s.id)}">${next.s.running ? '실습으로 돌아가기 →' : '▶ 시작하기'}</a>
            </div>`
          : `<div class="card continue"><span class="eyebrow">모두 통과</span><h3>🎉 모든 시나리오를 통과했어요!</h3><p>복습 일정이 되면 여기에 알려드릴게요.</p></div>`
      }
      <div class="card overall">
        <h2>전체 진행</h2>
        <div class="big-num">${done}<small> / ${scenarios.length}</small></div>
        ${progressBar(scenarios)}
        <div class="legend">
          <span>${stateIcon('done')} 통과</span><span>${stateIcon('review')} 복습</span>
          <span>${stateIcon('tried')} 도전 중</span><span>${stateIcon('new')} 새 문제</span>
        </div>
        ${
          due.length
            ? `<h2 style="margin-top:8px">↻ 복습 대기 ${due.length}</h2>
               <ul class="review-list">${due
                 .slice(0, 5)
                 .map((s) => `<li><a href="#${esc(s.id)}">${envOf(s.env).icon} ${esc(s.title)}</a></li>`)
                 .join('')}</ul>`
            : '<p class="muted" style="margin:0;font-size:13.5px">통과한 문제는 1일 → 3일 → 7일… 뒤에 복습을 추천해요.</p>'
        }
      </div>
    </div>

    <div class="env-cards">
      ${envs
        .map((env) => {
          const all = scenarios.filter((s) => s.env === env.id);
          const n = all.filter(isDone).length;
          return `<div class="card env-card">
            <div class="env-card-head">
              <span class="env-card-icon">${env.icon}</span>
              <div><h3>${esc(env.name)}</h3><p class="desc">${esc(env.description)}</p></div>
            </div>
            <div style="display:flex;gap:10px;align-items:center">${progressBar(all)}<span class="pct">${n}/${all.length}</span></div>
            <ul class="cat-list">
              ${groupByCategory(env, all)
                .map(({ cat, items }) => {
                  return `<li><button class="cat-row" data-cat="${esc(env.id)}:${esc(cat.id)}">
                    <span>${cat.icon}</span>
                    <span>${esc(cat.name)}<span class="sub">${esc(cat.description)}</span></span>
                    ${statusDots(items)}
                  </button></li>`;
                })
                .join('')}
            </ul>
          </div>`;
        })
        .join('')}
    </div>

    <ol class="how">
      <li><b>① 시작</b>문제 상황이 담긴 실습 환경이 만들어져요.</li>
      <li><b>② 실습</b>오른쪽 터미널에 직접 입력해요. 막히면 힌트 탭.</li>
      <li><b>③ 채점</b><kbd>Ctrl</kbd>+<kbd>Enter</kbd> 로 결과 상태를 검사해요.</li>
      <li><b>④ 복습</b>해설과 내 명령어를 비교하고, 며칠 뒤 다시 풀어요.</li>
    </ol>
  </div>`;
}

// 카테고리를 누르면 그 카테고리에서 아직 안 푼 첫 문제로
$('#home').addEventListener('click', (e) => {
  const row = e.target.closest('[data-cat]');
  if (!row) return;
  const [env, cat] = row.dataset.cat.split(':');
  const items = state.order.filter((s) => s.env === env && catOf(envOf(env), s.category).id === cat);
  const target = items.find((s) => !isDone(s)) ?? items[0];
  setCatOpen(env, cat, true);
  if (target) location.hash = target.id;
});

// ---------------- 상세 ----------------

async function openScenario(id) {
  disconnectTerminal();
  if (!id) {
    state.current = null;
    $('#home').hidden = false;
    $('#detail').hidden = true;
    document.title = 'Command Lab';
    renderTree();
    renderHome();
    return;
  }
  let detail;
  try {
    detail = await api(`/api/scenario?id=${encodeURIComponent(id)}`);
  } catch (err) {
    toast(err.message, 'error');
    location.hash = '';
    return;
  }
  state.current = detail;
  if (state.env !== detail.env) {
    state.env = detail.env;
    store.set('env', state.env);
  }
  document.title = `${detail.title} · Command Lab`;
  $('#home').hidden = true;
  $('#detail').hidden = false;
  renderHeader();
  $('#task').innerHTML = detail.taskHtml;
  enhanceMarkdown($('#task'));
  renderResult();
  renderHints();
  renderDebrief();
  renderHistory();
  selectTab('task');
  renderTree();
  $('.item.active')?.scrollIntoView({ block: 'nearest' });
  if (detail.running) connectTerminal();
  else showIdleOverlay();
}

function renderHeader() {
  const d = state.current;
  const env = envOf(d.env);
  const cat = catOf(env, d.category);
  const inCat = state.order.filter((s) => s.env === d.env && catOf(env, s.category).id === cat.id);
  const pos = inCat.findIndex((s) => s.id === d.id) + 1;
  $('#d-crumbs').innerHTML = `<a href="#">홈</a><span class="sep">›</span><span>${env.icon} ${esc(env.name)}</span>
    <span class="sep">›</span><span>${cat.icon} ${esc(cat.name)} <span class="muted">${pos}/${inCat.length}</span></span>`;
  const st = d.status.state;
  $('#d-title').innerHTML = `${esc(d.title)} <span class="pill ${st}">${STATE_NAME[st]}</span>${
    d.running ? '<span class="pill running">● 실행 중</span>' : ''
  }`;
  $('#d-meta').innerHTML = `${levelDots(d.level)} ${LEVEL_NAME[d.level] ?? ''} <span class="dot">·</span> ⏱ ${d.minutes}분
    ${d.status.attempts ? `<span class="dot">·</span> 시도 ${d.status.attempts}회` : ''}
    ${d.tags.map((t) => `<span class="tag">${esc(t)}</span>`).join('')}`;
  renderActions();
  const idx = state.order.findIndex((s) => s.id === d.id);
  $('#prev-btn').disabled = idx <= 0;
  $('#next-btn').disabled = idx < 0 || idx >= state.order.length - 1;
  $('#debrief-lock').textContent = d.status.passes > 0 || state.debriefOpen[d.id] ? '' : '🔒';
}

function renderActions() {
  const running = state.current.running;
  const el = $('#actions');
  el.innerHTML = running
    ? `<button class="btn success" data-act="check" title="Ctrl+Enter">✓ 채점 <kbd>Ctrl ↵</kbd></button>
       <button class="btn" data-act="start" title="처음 상태로 다시 만들기">↺ 처음부터</button>
       <button class="btn ghost" data-act="stop">■ 종료</button>`
    : `<button class="btn primary" data-act="start">▶ 시작</button>`;
  for (const b of el.querySelectorAll('button')) b.disabled = state.busy;
}

$('#actions').addEventListener('click', (e) => {
  const act = e.target.closest('[data-act]')?.dataset.act;
  if (act === 'start') start();
  if (act === 'check') check();
  if (act === 'stop') stop();
});

function go(delta) {
  if (!state.current) return;
  const idx = state.order.findIndex((s) => s.id === state.current.id);
  const target = state.order[idx + delta];
  if (target) location.hash = target.id;
}
$('#prev-btn').addEventListener('click', () => go(-1));
$('#next-btn').addEventListener('click', () => go(1));

// 탭
function selectTab(tab) {
  state.tab = tab;
  for (const b of $$('#tabs [role=tab]')) b.setAttribute('aria-selected', String(b.dataset.tab === tab));
  for (const p of $$('.tab-panel')) p.hidden = p.dataset.panel !== tab;
  $('#pane-body').scrollTop = 0;
}
$('#tabs').addEventListener('click', (e) => {
  const tab = e.target.closest('[data-tab]')?.dataset.tab;
  if (tab) selectTab(tab);
});

// 힌트: 하나씩 펼친다. 몇 개 봤는지는 브라우저에 기억
const hintKey = (id) => `hints.${id}`;
function renderHints() {
  const { id, hintsHtml } = state.current;
  const shown = Math.min(store.get(hintKey(id), 0), hintsHtml.length);
  $('#hint-badge').textContent = hintsHtml.length ? `${shown}/${hintsHtml.length}` : '';
  if (!hintsHtml.length) {
    $('#hints').innerHTML = '<p class="muted">이 시나리오에는 힌트가 없어요.</p>';
    return;
  }
  const opened = hintsHtml
    .slice(0, shown)
    .map((h, i) => `<div class="hint markdown"><div class="hint-label">💡 힌트 ${i + 1}/${hintsHtml.length}</div>${h}</div>`)
    .join('');
  const more =
    shown < hintsHtml.length
      ? `<div class="hint-locked">${shown === 0 ? '막혔을 때 하나씩 열어 보세요. 처음 힌트는 방향만 알려줘요.' : '아직 막혔나요?'}<br>
          <button class="btn" id="more-hint">💡 힌트 ${shown + 1} 보기</button></div>`
      : '<p class="muted" style="text-align:center;font-size:13.5px">모든 힌트를 열었어요. 그래도 어렵다면 해설 탭을 보세요.</p>';
  $('#hints').innerHTML = opened + more;
  enhanceMarkdown($('#hints'));
  $('#more-hint')?.addEventListener('click', () => {
    store.set(hintKey(id), shown + 1);
    renderHints();
    $('#hints .hint:last-of-type')?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  });
}

function renderDebrief() {
  const d = state.current;
  const el = $('#debrief');
  if (!d.debriefHtml) {
    el.innerHTML = '<p class="muted">이 시나리오에는 해설이 없어요.</p>';
    return;
  }
  if (d.status.passes > 0 || state.debriefOpen[d.id]) {
    el.innerHTML = `<div class="markdown">${d.debriefHtml}</div>`;
    enhanceMarkdown(el);
    return;
  }
  el.innerHTML = `<div class="locked"><div class="lock-icon">🔒</div>
    <p>해설은 통과한 뒤에 보면 훨씬 오래 기억에 남아요.<br>막혔다면 <b>힌트</b> 탭을 먼저 열어 보세요.</p>
    <button class="btn" id="peek">그래도 해설 보기</button></div>`;
  $('#peek').addEventListener('click', () => {
    state.debriefOpen[d.id] = true;
    renderDebrief();
    renderHeader();
  });
}

function renderHistory() {
  const d = state.current;
  const st = d.status;
  const hist = state.results[d.id]?.history ?? st.lastHistory ?? [];
  $('#history').innerHTML = `
    <div class="stats">
      <div class="stat"><b>${st.attempts ?? 0}</b><span>시도</span></div>
      <div class="stat"><b>${st.passes ?? 0}</b><span>통과</span></div>
      <div class="stat"><b>${st.nextReviewAt ? fmtDate(st.nextReviewAt) : '–'}</b><span>다음 복습</span></div>
    </div>
    <h3 style="font-size:14.5px;margin:0 0 6px">마지막으로 채점할 때까지 입력한 명령어</h3>
    ${
      hist.length
        ? `<pre class="history-list">${hist
            .slice(-60)
            .map((h) => `<span class="p">$ </span>${esc(h.cmd)}`)
            .join('\n')}</pre>`
        : '<p class="muted" style="font-size:14px">아직 기록이 없어요. 채점하면 터미널에 입력한 명령어가 여기에 남아요.</p>'
    }`;
}

function parseChecks(output) {
  return output
    .split('\n')
    .filter((l) => l.trim())
    .map((l) => {
      const cls = l.startsWith('✔') ? 'ok' : l.startsWith('✘') ? 'ng' : 'info';
      return `<li class="${cls}">${esc(cls === 'info' ? l : l.slice(1).trim())}</li>`;
    })
    .join('');
}

function renderResult() {
  const r = state.results[state.current.id];
  const el = $('#result');
  if (!r) {
    el.hidden = true;
    return;
  }
  const ok = (r.output.match(/^✔/gm) ?? []).length;
  const total = ok + (r.output.match(/^✘/gm) ?? []).length;
  el.className = `result ${r.passed ? 'pass' : 'fail'}`;
  el.innerHTML = `<div class="result-head">${r.passed ? '🎉 통과!' : `아직이에요 (${ok}/${total})`}
      <span class="when">${r.at.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' })} 채점</span></div>
    <ul class="checks">${parseChecks(r.output)}</ul>`;
  el.hidden = false;
}

// 코드 블록에 복사 버튼
function enhanceMarkdown(root) {
  for (const pre of root.querySelectorAll('pre')) {
    if (pre.querySelector('.copy-btn')) continue;
    const b = document.createElement('button');
    b.className = 'copy-btn';
    b.type = 'button';
    b.textContent = '복사';
    b.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(pre.querySelector('code')?.innerText ?? pre.innerText);
        b.textContent = '복사됨';
        setTimeout(() => (b.textContent = '복사'), 1200);
      } catch {
        toast('복사하지 못했어요. 직접 선택해서 복사하세요.', 'error');
      }
    });
    pre.appendChild(b);
  }
}

// ---------------- 시작 / 채점 / 종료 ----------------

const STEPS = ['환경 이미지 준비', '실습 컨테이너 만들기', '문제 상황 만들기', '터미널 연결'];

function setStep(n) {
  const el = $('#progress-steps');
  el.hidden = false;
  el.innerHTML = STEPS.map((s, i) => `<div class="${i < n ? 'done' : i === n ? 'doing' : ''}">${s}</div>`).join('');
}

async function start() {
  if (state.busy) return;
  const cur = state.current;
  if (cur.running && !confirm('지금까지 한 작업이 사라지고 문제를 처음 상태로 다시 만들어요. 계속할까요?')) return;
  state.busy = true;
  renderActions();
  disconnectTerminal();
  delete state.results[cur.id];
  renderResult();
  const log = $('#build-log');
  log.textContent = '';
  showOverlay({ icon: '⚙', spin: true, msg: '실습 환경을 준비하는 중...' });
  setStep(0);
  setConn('busy', '준비 중');
  try {
    const res = await fetch('/api/start', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: cur.id }),
    });
    if (!res.ok) throw new Error((await res.json().catch(() => ({}))).error || res.statusText);
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
        if (msg.type === 'error') error = msg.message;
        if (msg.type !== 'log') continue;
        log.textContent += `${msg.line}\n`;
        log.scrollTop = log.scrollHeight;
        if (msg.line.includes('빌드')) {
          $('#overlay-msg').textContent = '처음 한 번은 환경 이미지를 만드느라 몇 분 걸려요. 다음부터는 금방이에요.';
          $('#build-log-wrap').hidden = false;
        }
        if (msg.line.startsWith('실습 환경을 만드는')) setStep(1);
        if (msg.line.startsWith('문제 상황을 만드는')) setStep(2);
      }
    }
    if (error) throw new Error(error);
    if (state.current !== cur) return; // 그 사이 다른 시나리오로 이동함
    store.set(hintKey(cur.id), 0);
    cur.running = true;
    cur.status.attempts = (cur.status.attempts ?? 0) + 1;
    if (cur.status.state === 'new') cur.status.state = 'tried';
    setStep(3);
    renderHints();
    renderHeader();
    connectTerminal();
    loadCatalog();
  } catch (err) {
    showOverlay({ icon: '⚠', msg: `시작하지 못했어요: ${err.message}`, actions: [{ label: '다시 시도', primary: true, onClick: start }] });
    $('#build-log-wrap').hidden = !log.textContent;
    setConn('', '연결 안 됨');
  } finally {
    state.busy = false;
    if (state.current) renderActions();
  }
}

async function check() {
  const cur = state.current;
  if (!cur?.running || state.busy) return;
  state.busy = true;
  renderActions();
  try {
    const r = await api('/api/check', { id: cur.id });
    state.results[cur.id] = { ...r, at: new Date() };
    if (state.current !== cur) return;
    if (r.passed) {
      const wasFirst = cur.status.passes === 0;
      cur.status.passes += 1;
      cur.status.nextReviewAt = r.progress?.nextReviewAt ?? cur.status.nextReviewAt;
      await loadCatalog();
      cur.status.state = byId(cur.id)?.status.state ?? 'done';
      renderHeader();
      renderDebrief();
      showPassDialog(r, wasFirst);
    } else {
      selectTab('task');
      toast('아직 통과하지 못했어요. ✘ 항목을 확인해 보세요.', 'info', 2500);
    }
    renderResult();
    renderHistory();
  } catch (err) {
    toast(err.message, 'error');
  } finally {
    state.busy = false;
    if (state.current) renderActions();
    state.term?.focus();
  }
}

async function stop() {
  if (!confirm('실습 환경을 종료할까요? (학습 기록은 남아요)')) return;
  disconnectTerminal();
  try {
    await api('/api/stop', { id: state.current.id });
  } catch (err) {
    toast(err.message, 'error');
  }
  state.current.running = false;
  renderHeader();
  showIdleOverlay('실습을 종료했어요.');
  loadCatalog();
}

function nextAfterCurrent() {
  const idx = state.order.findIndex((s) => s.id === state.current.id);
  const rest = [...state.order.slice(idx + 1), ...state.order.slice(0, idx)];
  return rest.find((s) => s.env === state.current.env && !isDone(s)) ?? rest.find((s) => !isDone(s)) ?? null;
}

function showPassDialog(r, wasFirst) {
  const dlg = $('#pass-dialog');
  const next = nextAfterCurrent();
  $('#pass-title').textContent = wasFirst ? '통과!' : '복습 완료!';
  $('#pass-sub').textContent = r.progress?.nextReviewAt
    ? `다음 복습은 ${fmtDate(r.progress.nextReviewAt)}에 추천할게요.`
    : '잘했어요!';
  $('#pass-checks').innerHTML = parseChecks(r.output);
  $('#pass-history').hidden = !r.history.length;
  $('#pass-history-list').textContent = r.history
    .slice(-40)
    .map((h) => `$ ${h.cmd}`)
    .join('\n');
  const nextBtn = $('#pass-next');
  nextBtn.hidden = !next;
  nextBtn.textContent = next ? `다음: ${next.title} →` : '';
  nextBtn.onclick = () => {
    dlg.close();
    if (next) location.hash = next.id;
  };
  $('#pass-debrief').onclick = () => {
    dlg.close();
    selectTab('debrief');
  };
  dlg.showModal();
  (next ? nextBtn : $('#pass-debrief')).focus();
}

// ---------------- 터미널 ----------------

function setConn(kind, text) {
  const el = $('#conn');
  el.className = `conn ${kind}`;
  el.querySelector('span').textContent = text;
}

function showOverlay({ icon = '▶', spin = false, msg, actions = [] }) {
  $('#overlay').hidden = false;
  const ic = $('#overlay-icon');
  ic.textContent = icon;
  ic.classList.toggle('spin', spin);
  $('#overlay-msg').textContent = msg;
  $('#progress-steps').hidden = true;
  $('#build-log-wrap').hidden = true;
  const box = $('#overlay-actions');
  box.innerHTML = '';
  for (const a of actions) {
    const b = document.createElement('button');
    b.className = `btn${a.primary ? ' primary big' : ''}`;
    b.textContent = a.label;
    b.addEventListener('click', a.onClick);
    box.appendChild(b);
  }
}

function showIdleOverlay(msg) {
  setConn('', '연결 안 됨');
  // Docker 가 없으면 시작해도 실패하므로, 먼저 무엇이 필요한지 알려준다
  if (!msg && state.catalog?.dockerOk === false) {
    showOverlay({
      icon: '⚠',
      msg: 'Docker에 연결할 수 없어 실습을 시작할 수 없어요. Docker Desktop을 실행한 뒤 다시 확인해 주세요.',
      actions: [{ label: '↻ 다시 확인', primary: true, onClick: () => location.reload() }],
    });
    return;
  }
  showOverlay({
    icon: '▶',
    msg: msg ?? '시작하면 문제 상황이 담긴 실습 환경이 만들어지고, 여기에 터미널이 열려요.',
    actions: [{ label: '▶ 시작', primary: true, onClick: start }],
  });
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
  const term = new Terminal({
    cursorBlink: true,
    fontSize: state.fontSize,
    fontFamily: getComputedStyle(document.documentElement).getPropertyValue('--mono'),
    scrollback: 5000,
    allowProposedApi: true,
    theme: {
      background: '#0f131a',
      foreground: '#e3e8ef',
      cursor: '#5b8cff',
      selectionBackground: '#3b4a6080',
      black: '#1d2531',
      brightBlack: '#5c6878',
    },
  });
  const fit = new FitAddon.FitAddon();
  term.loadAddon(fit);
  term.open($('#term'));
  fit.fit();
  state.term = term;
  state.fit = fit;
  term.attachCustomKeyEventHandler((e) => {
    if (e.type !== 'keydown') return true;
    // Ctrl/⌘+Enter 는 셸로 보내지 않고 채점
    if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) {
      check();
      return false;
    }
    // 복사·붙여넣기 (맥의 ⌘C/⌘V 는 브라우저가 원래 처리한다)
    if (e.ctrlKey && !e.metaKey && !e.altKey) {
      const key = e.key.toLowerCase();
      // Ctrl+C: 선택한 글자가 있으면 복사, 없으면 셸에 ^C (실행 중인 명령 멈추기)
      // Ctrl+Shift+C: 항상 복사 (브라우저의 개발자 도구 단축키를 막는다)
      if (key === 'c' && (e.shiftKey || term.hasSelection())) {
        e.preventDefault();
        if (term.hasSelection()) {
          navigator.clipboard?.writeText(term.getSelection()).then(() => toast('복사했어요', 'info', 1500), () => {});
          term.clearSelection();
        }
        return false;
      }
      // Ctrl+V / Ctrl+Shift+V: 셸에 ^V 를 보내지 않고 브라우저의 붙여넣기에 맡긴다
      if (key === 'v') return false;
    }
    return true;
  });

  setConn('busy', '연결 중');
  const id = state.current.id;
  const proto = location.protocol === 'https:' ? 'wss' : 'ws';
  const ws = new WebSocket(
    `${proto}://${location.host}/ws/terminal?id=${encodeURIComponent(id)}&cols=${term.cols}&rows=${term.rows}`,
  );
  ws.binaryType = 'arraybuffer';
  state.ws = ws;
  ws.onopen = () => {
    $('#overlay').hidden = true;
    setConn('on', `${envOf(state.current.env)?.name ?? ''} · 연결됨`);
    term.focus();
  };
  ws.onmessage = (ev) => term.write(typeof ev.data === 'string' ? ev.data : new Uint8Array(ev.data));
  ws.onclose = (ev) => {
    if (state.ws !== ws) return;
    state.ws = null;
    setConn('', '연결 끊김');
    const exited = ev.code === 1000;
    showOverlay({
      icon: exited ? '⏏' : '⚠',
      msg: exited ? '셸에서 나왔어요. 실습 환경은 그대로 있어요.' : `터미널 연결이 끊겼어요. ${ev.reason || ''}`,
      actions: [
        { label: '✓ 채점하기', primary: true, onClick: check },
        { label: '다시 접속', onClick: connectTerminal },
      ],
    });
  };
  term.onData((d) => ws.readyState === WebSocket.OPEN && ws.send(JSON.stringify({ t: 'i', d })));
  term.onResize(({ cols, rows }) => ws.readyState === WebSocket.OPEN && ws.send(JSON.stringify({ t: 'r', cols, rows })));
}

function refit() {
  try {
    state.fit?.fit();
  } catch {
    /* 숨겨진 상태에서는 무시 */
  }
}
new ResizeObserver(refit).observe($('#term'));

function setFont(size) {
  state.fontSize = Math.max(10, Math.min(24, size));
  store.set('fontSize', state.fontSize);
  if (state.term) {
    state.term.options.fontSize = state.fontSize;
    refit();
  }
}
$('#font-up').addEventListener('click', () => setFont(state.fontSize + 1));
$('#font-down').addEventListener('click', () => setFont(state.fontSize - 1));

$('#focus-btn').addEventListener('click', () => {
  const ws = $('#workspace');
  ws.classList.toggle('focus');
  $('#focus-btn').textContent = ws.classList.contains('focus') ? '⇥' : '⇤';
  setTimeout(refit, 50);
  state.term?.focus();
});

// 패널 크기 조절
(() => {
  const ws = $('#workspace');
  const sp = $('#splitter');
  const apply = (pct) => {
    const v = Math.max(22, Math.min(70, pct));
    ws.style.setProperty('--split', `${v}%`);
    return v;
  };
  let pct = apply(store.get('split', 42));
  sp.addEventListener('pointerdown', (e) => {
    sp.setPointerCapture(e.pointerId);
    sp.classList.add('dragging');
  });
  sp.addEventListener('pointermove', (e) => {
    if (!sp.hasPointerCapture(e.pointerId)) return;
    const r = ws.getBoundingClientRect();
    pct = apply(((e.clientX - r.left) / r.width) * 100);
  });
  sp.addEventListener('pointerup', (e) => {
    sp.releasePointerCapture(e.pointerId);
    sp.classList.remove('dragging');
    store.set('split', pct);
    refit();
  });
  sp.addEventListener('dblclick', () => {
    pct = apply(42);
    store.set('split', pct);
    refit();
  });
  sp.addEventListener('keydown', (e) => {
    if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight') return;
    pct = apply(pct + (e.key === 'ArrowLeft' ? -2 : 2));
    store.set('split', pct);
    refit();
  });
})();

// ---------------- 테마, 도움말, 단축키 ----------------

const THEMES = [
  { id: null, icon: '🌓', label: '시스템 설정' },
  { id: 'light', icon: '☀️', label: '라이트' },
  { id: 'dark', icon: '🌙', label: '다크' },
];
function applyTheme(id) {
  if (id) document.documentElement.dataset.theme = id;
  else delete document.documentElement.dataset.theme;
  const t = THEMES.find((x) => x.id === id) ?? THEMES[0];
  $('#theme-btn').textContent = t.icon;
  $('#theme-btn').title = `테마: ${t.label}`;
}
applyTheme(store.get('theme', null));
$('#theme-btn').addEventListener('click', () => {
  const cur = store.get('theme', null);
  const next = THEMES[(THEMES.findIndex((t) => t.id === cur) + 1) % THEMES.length];
  store.set('theme', next.id);
  applyTheme(next.id);
  toast(`테마: ${next.label}`, 'info', 1200);
});

$('#help-btn').addEventListener('click', () => $('#help-dialog').showModal());
for (const b of $$('[data-close]')) b.addEventListener('click', () => b.closest('dialog').close());
for (const d of $$('dialog')) {
  d.addEventListener('click', (e) => {
    if (e.target === d) d.close(); // 바깥 클릭으로 닫기
  });
  d.addEventListener('close', () => state.term?.focus());
}

document.addEventListener('keydown', (e) => {
  const typing = e.target.closest?.('input, textarea, [contenteditable]');
  if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
    e.preventDefault();
    check();
    return;
  }
  if (e.key === 'Escape' && $('#sidebar').classList.contains('open')) {
    closeSidebar();
    $('#menu-btn').focus();
    return;
  }
  if (typing) return; // 터미널(textarea)이나 검색창에 입력 중이면 아래 단축키는 쓰지 않는다
  if (e.key === '/') {
    e.preventDefault();
    if (matchMedia('(max-width: 900px)').matches) openSidebar();
    $('#search').focus();
  } else if (e.key === '?') {
    $('#help-dialog').showModal();
  } else if (e.altKey && e.key === 'ArrowLeft') {
    go(-1);
  } else if (e.altKey && e.key === 'ArrowRight') {
    go(1);
  }
});

// ---------------- 시작 ----------------

const route = () => openScenario(decodeURIComponent(location.hash.slice(1)));
window.addEventListener('hashchange', route);
loadCatalog()
  .then(route)
  .catch((err) => {
    $('#tree').innerHTML = `<p class="empty">목록을 불러오지 못했어요: ${esc(err.message)}</p>`;
  });
