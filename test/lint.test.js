// 문서 형식 검사기 테스트: node --test test/
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { lintScenario } from '../src/lint.js';

const META = { title: 't', category: 'c', summary: 's', level: 1, minutes: 5, tags: ['x'] };
const TASK = '# 제목\n\n## 목표\n1. 하기\n';

function lint(files, meta = META) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'lint-'));
  for (const [f, text] of Object.entries({ 'task.md': TASK, 'hints.md': 'a\n---\nb', 'debrief.md': 'd', 'solution.sh': 'x', ...files })) {
    fs.writeFileSync(path.join(dir, f), text);
  }
  return lintScenario({ dir }, meta);
}
const errs = (files, meta) => lint(files, meta).errors;

test('정상 문서는 통과', () => {
  assert.deepEqual(lint({}), { errors: [], warnings: [] });
});

test('표 안 코드의 | 를 이스케이프하지 않으면 칸이 어긋난다 (\\| 는 괜찮다)', () => {
  const head = '| 명령어 | 하는 일 |\n|---|---|\n';
  assert.match(errs({ 'task.md': TASK + head + '| `a | b` | 설명 |\n' })[0], /칸 수/);
  assert.deepEqual(errs({ 'task.md': TASK + head + '| `a \\| b` | 설명 |\n' }), []);
});

test('인라인 코드 안의 \\` (aws/46 힌트에서 실제로 깨졌던 모양)', () => {
  const bad = "`--query 'x[?r < \\`400\\`].n'`";
  assert.match(errs({ 'hints.md': `a\n---\n${bad}` })[0], /이스케이프가 안 돼요/);
  // 코드 블록 안은 괜찮고, 역슬래시로 끝나는 경로도 괜찮다 (linux/22)
  assert.deepEqual(errs({ 'hints.md': "a\n---\n```\nq < \\`400\\`\n```" }), []);
  assert.deepEqual(errs({ 'debrief.md': '키는 `C:\\Users\\이름\\.ssh\\` 에 생겨요' }), []);
  assert.deepEqual(errs({ 'debrief.md': '두 개로 감싸기 ``a `b` c`` 는 괜찮다' }), []);
});

test('닫히지 않은 인라인 코드와 코드 블록', () => {
  assert.match(errs({ 'debrief.md': '이건 `열고 안 닫음' })[0], /닫히지 않은 인라인 코드/);
  assert.match(errs({ 'debrief.md': '```bash\nls\n' })[0], /닫히지 않은 코드 블록/);
});

test('메타데이터와 힌트', () => {
  assert.ok(errs({}, { ...META, level: 4 }).some((e) => /level/.test(e)));
  assert.ok(errs({}, { ...META, tags: [] }).some((e) => /tags/.test(e)));
  assert.ok(errs({ 'hints.md': 'a\n---\n---\nb' }).some((e) => /비어 있는 힌트/.test(e)));
  assert.ok(lint({ 'hints.md': 'a' }).warnings.some((w) => /힌트가 1개/.test(w)));
  assert.ok(errs({ 'task.md': '제목 없음\n' }).some((e) => /첫 줄/.test(e)));
});
