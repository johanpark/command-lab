cat > ~/collect.mjs <<'JS'
import fs from 'node:fs';
const base = 'http://localhost:8080';
let url = '/api/users?per_page=50';
const all = [];
while (url) {
  const res = await fetch(base + url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const body = await res.json();
  all.push(...body.data);
  url = body.next;
}
fs.writeFileSync(process.env.HOME + '/users.json', JSON.stringify(all, null, 2));
fs.writeFileSync(process.env.HOME + '/answer.txt', all.filter((u) => u.active).length + '\n');
console.log(`${all.length}명 저장`);
JS
node ~/collect.mjs
