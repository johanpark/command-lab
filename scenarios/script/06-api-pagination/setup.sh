#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
rm -f "$H/users.json"
cat > /opt/cmdlab/secret/api.js <<'JS'
const http = require('http');
const fs = require('fs');
let seed = Number(process.argv[2]) || 1;
const rnd = () => ((seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648);
const pick = (a) => a[Math.floor(rnd() * a.length)];
const last = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임', '한', '오', '서', '신', '권'];
const first = ['민준', '서연', '도윤', '하은', '시우', '지유', '예준', '수아', '주원', '지아', '하준', '서윤', '은우', '채원'];
const teams = ['platform', 'payments', 'search', 'mobile', 'data', 'design'];
const n = 70 + Math.floor(rnd() * 60);
const users = Array.from({ length: n }, (_, i) => ({
  id: 1001 + i,
  name: pick(last) + pick(first),
  email: `user${1001 + i}@corp.example`,
  team: pick(teams),
  active: rnd() < 0.85,
}));
fs.writeFileSync('/opt/cmdlab/secret/users.json', JSON.stringify(users));
http.createServer((req, res) => {
  const u = new URL(req.url, 'http://localhost');
  const json = (code, body) => { res.writeHead(code, { 'Content-Type': 'application/json' }); res.end(JSON.stringify(body, null, 2) + '\n'); };
  if (u.pathname !== '/api/users') return json(404, { error: 'not found', hint: 'GET /api/users' });
  const perPage = Math.min(Math.max(parseInt(u.searchParams.get('per_page') || '20', 10) || 20, 1), 50);
  const page = Math.max(parseInt(u.searchParams.get('page') || '1', 10) || 1, 1);
  const data = users.slice((page - 1) * perPage, page * perPage);
  const more = page * perPage < users.length;
  json(200, { data, page, per_page: perPage, total: users.length, next: more ? `/api/users?page=${page + 1}&per_page=${perPage}` : null });
}).listen(8080, '127.0.0.1');
JS
pkill -f /opt/cmdlab/secret/api.js 2>/dev/null || true
setsid nohup node /opt/cmdlab/secret/api.js "$RANDOM" > /dev/null 2>&1 < /dev/null &
for i in $(seq 1 40); do curl -sf localhost:8080/api/users > /dev/null && break; sleep 0.25; done
