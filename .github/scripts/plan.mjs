// CI 에서 테스트할 시나리오를 고르고, 환경별·크기별로 나눠 병렬 실행 목록(matrix)을 만든다.
//   PR      : 바뀐 파일만 보고 고른다 (엔진·CI 가 바뀌면 전체, envs/<환경> 이 바뀌면 그 환경 전체)
//   그 외    : 전체 (develop·main push, 매일 밤, 수동 실행)
// 출력: GITHUB_OUTPUT 에 matrix=[{"name":"aws 1/3","env":"aws","targets":"aws/01-... aws/02-..."}, ...]
import { execSync } from 'node:child_process';
import fs from 'node:fs';
import { loadCatalog, loadTraps } from '../../src/catalog.js';

const SHARD_WEIGHT = 40; // 조각 하나의 크기: 시나리오 1 + 함정 수 (컨테이너 하나 ≈ 20초)
const { envs, scenarios } = loadCatalog();
const weight = (s) => 1 + loadTraps(s).length;

let picked;
const base = process.env.BASE_SHA;
if (process.env.GITHUB_EVENT_NAME === 'pull_request' && base) {
  const files = execSync(`git diff --name-only ${base}...HEAD`, { encoding: 'utf8' }).split('\n').filter(Boolean);
  const everything = files.some((f) => /^(src|bin|lib|\.github)\//.test(f) || /^package(-lock)?\.json$/.test(f));
  const envTouched = new Set(files.map((f) => f.match(/^envs\/([^/]+)\//)?.[1]).filter(Boolean));
  const dirs = new Set(files.map((f) => f.match(/^scenarios\/([^/]+\/[^/]+)\//)?.[1]).filter(Boolean));
  picked = scenarios.filter((s) => everything || envTouched.has(s.env) || dirs.has(s.id));
  console.log(`바뀐 파일 ${files.length}개 → ${everything ? '엔진/CI 변경: 전체' : `환경 [${[...envTouched]}] + 시나리오 ${dirs.size}개`}`);
} else {
  picked = scenarios;
}

const matrix = [];
for (const env of envs) {
  const list = picked.filter((s) => s.env === env.id);
  if (!list.length) continue;
  // 조각 수를 먼저 정하고, 순서대로 비슷한 크기로 채운다
  const total = list.reduce((a, s) => a + weight(s), 0);
  const n = Math.max(1, Math.ceil(total / SHARD_WEIGHT));
  const shards = [[]];
  let w = 0;
  for (const s of list) {
    if (w >= (total / n) * shards.length && shards.length < n) shards.push([]);
    shards.at(-1).push(s.id);
    w += weight(s);
  }
  shards.forEach((ids, i) =>
    matrix.push({ name: shards.length > 1 ? `${env.id} ${i + 1}/${shards.length}` : env.id, env: env.id, targets: ids.join(' ') }),
  );
}
console.log(`시나리오 ${picked.length}개 → 작업 ${matrix.length}개`);
matrix.forEach((m) => console.log(`  ${m.name}: ${m.targets.split(' ').length}개`));
if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, `matrix=${JSON.stringify(matrix)}\n`);
