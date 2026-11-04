// 난이도 가늠: 첫 통과까지의 기록(걸린 시간, 채점 실패 수, 본 힌트 수)을 문제의 레벨·예상 시간과 비교한다.
// 기록은 각자 컴퓨터(~/.cmdlab/progress.json)에만 있으므로, 내가 풀어 본 결과로 레벨 조정 후보를 고르는 용도.

// → null (아직 첫 통과 기록이 없음) | { minutes, fails, hints, ratio, felt, verdict: 'harder' | 'easier' | 'ok', why: [...] }
export function feltDifficulty(scenario, status) {
  if (status.solveSeconds == null) return null;
  const minutes = Math.max(1, Math.round(status.solveSeconds / 60));
  const fails = status.failsBeforePass ?? 0;
  const hints = status.hintsBeforePass ?? 0;
  const ratio = minutes / (scenario.minutes || 10);
  const why = [];
  let felt = scenario.level;
  if (ratio >= 2) { felt += 1; why.push(`예상 ${scenario.minutes}분 → ${minutes}분`); }
  if (hints >= 3) { felt += 1; why.push(`힌트 ${hints}개`); }
  if (fails >= 3) { felt += 1; why.push(`채점 실패 ${fails}번`); }
  const easy = ratio <= 0.5 && hints === 0 && fails <= 1;
  if (easy) { felt -= 1; why.push(`예상 ${scenario.minutes}분 → ${minutes}분, 힌트 없이`); }
  felt = Math.min(Math.max(felt, 1), 4);
  const verdict = felt > scenario.level ? 'harder' : felt < scenario.level ? 'easier' : 'ok';
  return { minutes, fails, hints, ratio, felt, verdict, why };
}
