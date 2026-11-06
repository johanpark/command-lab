// 시나리오 문서 형식 검사 (lab validate 에서 사용)
// 화면에서 실제로 깨져 보이는 실수(닫히지 않은 코드, 표 칸 어긋남 등)와 빠진 메타데이터를 잡는다.
import fs from 'node:fs';
import path from 'node:path';

const read = (dir, f) => (fs.existsSync(path.join(dir, f)) ? fs.readFileSync(path.join(dir, f), 'utf8').replace(/\r\n/g, '\n') : null);

// GFM 표 칸 나누기: 역슬래시로 이스케이프하지 않은 | 는 코드 안이라도 칸을 나눈다
function cells(line) {
  const t = line.trim().replace(/^\|/, '').replace(/\|$/, '');
  return t.split(/(?<!\\)\|/).length;
}

// 인라인 코드: 같은 길이의 백틱으로 열고 닫는다 (CommonMark). 닫히지 않은 여는 백틱을 찾는다
function unclosedCode(line) {
  const runs = [...line.matchAll(/`+/g)];
  for (let i = 0; i < runs.length; i++) {
    const n = runs[i][0].length;
    const j = runs.findIndex((r, k) => k > i && r[0].length === n);
    if (j < 0) return runs[i].index;
    i = j;
  }
  return -1;
}

function lintMarkdown(text, file) {
  const out = [];
  const lines = text.split('\n');
  let fence = null;
  let table = null; // 표 머리글의 칸 수
  lines.forEach((line, i) => {
    const at = `${file}:${i + 1}`;
    const f = line.match(/^\s*(```+|~~~+)/);
    if (f) {
      if (!fence) fence = { mark: f[1][0], line: i + 1 };
      else if (f[1][0] === fence.mark) fence = null;
      table = null;
      return;
    }
    if (fence) return;
    if (/\\`[^\s.,;:)\]]/.test(line)) {
      out.push(`${at}: 인라인 코드 안의 \\\` 는 이스케이프가 안 돼요. 백틱이 든 코드는 \`\` 두 개로 감싸거나 코드 블록(\`\`\`)으로`);
    } else if (unclosedCode(line) >= 0) {
      out.push(`${at}: 닫히지 않은 인라인 코드(\`) 가 있어요`);
    }
    if (/^\s*\|/.test(line)) {
      const next = lines[i + 1] ?? '';
      if (table === null && /^\s*\|?\s*:?-{3,}/.test(next)) table = cells(line);
      else if (table !== null && !/^\s*\|?\s*:?-{3,}/.test(line) && cells(line) !== table) {
        out.push(`${at}: 표의 칸 수가 머리글(${table})과 달라요(${cells(line)}). 코드 안의 | 는 \\| 로 쓰세요`);
      }
    } else table = null;
  });
  if (fence) out.push(`${file}:${fence.line}: 닫히지 않은 코드 블록(${fence.mark.repeat(3)})`);
  return out;
}

// → { errors: [...], warnings: [...] }  (메시지 앞에 시나리오 ID 는 붙이지 않는다)
export function lintScenario(s, meta) {
  const errors = [];
  const warnings = [];
  for (const k of ['title', 'category', 'summary']) if (!meta?.[k]) errors.push(`scenario.yaml: ${k} 가 없어요`);
  if (![1, 2, 3].includes(meta?.level)) errors.push(`scenario.yaml: level 은 1, 2, 3 중 하나 (지금: ${meta?.level})`);
  if (typeof meta?.minutes !== 'number') errors.push('scenario.yaml: minutes 는 숫자여야 해요');
  if (!Array.isArray(meta?.tags) || !meta.tags.length) errors.push('scenario.yaml: tags 가 비어 있어요');

  const task = read(s.dir, 'task.md');
  if (task !== null) {
    if (!/^# \S/.test(task)) errors.push('task.md: 첫 줄은 "# 제목" 이어야 해요');
    if (!/^## 목표/m.test(task)) warnings.push('task.md: "## 목표" 단락이 없어요');
  }
  const hints = read(s.dir, 'hints.md');
  if (hints === null) warnings.push('hints.md 가 없어요');
  else {
    const parts = hints.split(/^---\s*$/m).map((h) => h.trim());
    if (parts.some((h) => !h)) errors.push('hints.md: 비어 있는 힌트가 있어요 (--- 가 연달아 있거나 맨 앞·뒤에 있음)');
    if (parts.length < 2 || parts.length > 6) warnings.push(`hints.md: 힌트가 ${parts.length}개예요 (2~6개 권장)`);
  }
  if (read(s.dir, 'debrief.md') === null) warnings.push('debrief.md(해설) 가 없어요');
  const traps = path.join(s.dir, 'traps');
  if (!fs.existsSync(traps) || !fs.readdirSync(traps).some((f) => /\.(sh|ps1)$/.test(f))) {
    warnings.push('함정 테스트(traps/)가 없어요. 학습자가 할 법한 틀린 풀이를 하나 이상 넣어 주세요');
  }
  if (!['solution.sh', 'solution.ps1'].some((f) => fs.existsSync(path.join(s.dir, f)))) {
    warnings.push('모범 풀이(solution.sh/.ps1) 가 없어 lab test 로 검증할 수 없어요');
  }
  for (const f of ['task.md', 'hints.md', 'debrief.md']) {
    const text = read(s.dir, f);
    if (text !== null) errors.push(...lintMarkdown(text, f));
  }
  return { errors, warnings };
}
