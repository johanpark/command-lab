# 설명: next 를 따라가지 않으면 첫 페이지 직원만 모인다
# 실패해야: 모든 직원이 한 번씩
# 실패해야: 재직 중인 직원 수
cat > ~/collect.mjs <<'JS'
import fs from 'node:fs';
const base = 'http://localhost:8080';
let url = '/api/users?per_page=50';
const first = true;
const all = [];
while (url) {
  const res = await fetch(base + url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const body = await res.json();
  all.push(...body.data);
  url = null; // 첫 페이지만
}
fs.writeFileSync(process.env.HOME + '/users.json', JSON.stringify(all, null, 2));
fs.writeFileSync(process.env.HOME + '/answer.txt', all.filter((u) => u.active).length + '\n');
console.log(`${all.length}명 저장`);
JS
node ~/collect.mjs
