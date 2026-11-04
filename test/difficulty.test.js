// 체감 난이도 판정 테스트: node --test 'test/*.test.js'
import assert from 'node:assert/strict';
import test from 'node:test';
import { feltDifficulty } from '../src/difficulty.js';

const S = { level: 2, minutes: 20 };
const st = (min, fails, hints) => ({ solveSeconds: min * 60, failsBeforePass: fails, hintsBeforePass: hints });

test('첫 통과 기록이 없으면 판정하지 않는다', () => {
  assert.equal(feltDifficulty(S, { solveSeconds: null }), null);
});

test('예상과 비슷하면 ok', () => {
  assert.equal(feltDifficulty(S, st(25, 1, 1)).verdict, 'ok');
});

test('시간 2배·힌트 3개·실패 3번은 각각 한 단계씩 어렵게', () => {
  assert.equal(feltDifficulty(S, st(40, 0, 0)).felt, 3);
  const f = feltDifficulty(S, st(45, 3, 3));
  assert.equal(f.felt, 4);
  assert.equal(f.verdict, 'harder');
  assert.equal(f.why.length, 3);
});

test('절반 이하 시간에 힌트 없이 풀면 쉬움, 레벨 1 아래로는 안 내려간다', () => {
  assert.equal(feltDifficulty(S, st(8, 1, 0)).verdict, 'easier');
  assert.equal(feltDifficulty({ level: 1, minutes: 20 }, st(5, 0, 0)).verdict, 'ok');
  assert.equal(feltDifficulty(S, st(8, 0, 1)).verdict, 'ok'); // 힌트를 봤으면 쉬웠다고 보지 않는다
});
