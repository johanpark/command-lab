// 학습 기록: 시도/통과 횟수, 복습 일정(간격 반복), 마지막으로 입력한 명령어,
// 그리고 난이도를 가늠할 첫 통과까지의 채점 실패 수·본 힌트 수·걸린 시간.
// 저장 위치: ~/.cmdlab/progress.json (CMDLAB_HOME 으로 변경 가능)
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const DATA_DIR = process.env.CMDLAB_HOME ?? path.join(os.homedir(), '.cmdlab');
const FILE = path.join(DATA_DIR, 'progress.json');
const DAY = 24 * 60 * 60 * 1000;
// 통과할 때마다 다음 복습까지의 간격이 늘어난다 (일 단위)
export const REVIEW_INTERVALS = [1, 3, 7, 14, 30, 60];

export function loadProgress() {
  try {
    const data = JSON.parse(fs.readFileSync(FILE, 'utf8'));
    return { current: null, scenarios: {}, ...data };
  } catch {
    return { current: null, scenarios: {} };
  }
}

function save(data) {
  fs.mkdirSync(DATA_DIR, { recursive: true });
  const tmp = `${FILE}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(data, null, 2));
  fs.renameSync(tmp, FILE);
}

function entry(data, id) {
  data.scenarios[id] ??= { attempts: 0, passes: 0, streak: 0 };
  return data.scenarios[id];
}

export function recordStart(id) {
  const data = loadProgress();
  const e = entry(data, id);
  e.attempts += 1;
  e.lastStartedAt = new Date().toISOString();
  e.firstStartedAt ??= e.lastStartedAt;
  data.current = id;
  save(data);
}

export function recordCheck(id, { passed, history }) {
  const data = loadProgress();
  const e = entry(data, id);
  const now = Date.now();
  e.lastCheckedAt = new Date(now).toISOString();
  e.checks = (e.checks ?? 0) + 1;
  if (!passed && !e.passes) e.failsBeforePass = (e.failsBeforePass ?? 0) + 1;
  if (passed && !e.passes) {
    // 첫 통과: 이번 실습을 시작한 뒤 걸린 시간, 그때까지 본 힌트 수를 남긴다 (난이도 가늠용)
    e.hintsBeforePass = e.hintsSeen ?? 0;
    e.failsBeforePass ??= 0;
    if (e.lastStartedAt) e.solveSeconds = Math.max(0, Math.round((now - Date.parse(e.lastStartedAt)) / 1000));
  }
  if (history?.length) e.lastHistory = history.slice(-200);
  if (passed) {
    // 복습 시기가 됐을 때(또는 첫 통과) 통과해야 간격이 늘어난다.
    const due = !e.nextReviewAt || now >= Date.parse(e.nextReviewAt);
    if (due) {
      e.streak = Math.min(e.streak + 1, REVIEW_INTERVALS.length);
      e.nextReviewAt = new Date(now + REVIEW_INTERVALS[e.streak - 1] * DAY).toISOString();
    }
    e.passes += 1;
    e.firstPassedAt ??= new Date(now).toISOString();
    e.lastPassedAt = new Date(now).toISOString();
  }
  save(data);
  return e;
}

// n번째 힌트까지 봤다 (웹·CLI). 가장 많이 본 개수만 남긴다
export function recordHint(id, n) {
  const data = loadProgress();
  const e = entry(data, id);
  e.hintsSeen = Math.max(e.hintsSeen ?? 0, Number(n) || 0);
  save(data);
  return e;
}

export function setCurrent(id) {
  const data = loadProgress();
  data.current = id;
  save(data);
}

export function scenarioStatus(progress, id) {
  const e = progress.scenarios[id];
  if (!e) return { state: 'new', attempts: 0, passes: 0 };
  const passed = e.passes > 0;
  const due = passed && e.nextReviewAt && Date.now() >= Date.parse(e.nextReviewAt);
  return {
    state: !passed ? (e.attempts > 0 ? 'tried' : 'new') : due ? 'review' : 'done',
    attempts: e.attempts,
    passes: e.passes,
    streak: e.streak,
    nextReviewAt: e.nextReviewAt ?? null,
    lastStartedAt: e.lastStartedAt ?? null,
    lastPassedAt: e.lastPassedAt ?? null,
    lastHistory: e.lastHistory ?? [],
    hintsSeen: e.hintsSeen ?? 0,
    failsBeforePass: e.failsBeforePass ?? 0,
    hintsBeforePass: e.hintsBeforePass ?? null,
    solveSeconds: e.solveSeconds ?? null,
  };
}
