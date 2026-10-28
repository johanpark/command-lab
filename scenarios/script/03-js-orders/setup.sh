#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p "$H/tools"; rm -rf "$H/orders" "$H/report"; mkdir -p "$H/orders"
node - "$H/orders" "$RANDOM" <<'JS'
const fs = require('fs'), path = require('path');
const [dir, seedArg] = process.argv.slice(2);
let seed = Number(seedArg) || 1;
const rnd = () => ((seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648);
const pick = (a) => a[Math.floor(rnd() * a.length)];
const products = [['KB-01', 89000], ['MS-02', 39000], ['MN-27', 329000], ['NB-14', 1250000], ['CB-05', 9900], ['TB-11', 690000]];
const customers = ['kim', 'lee', 'park', 'choi', 'jung', 'kang', 'cho', 'yoon'];
const n = 120 + Math.floor(rnd() * 60);
const nBroken = 2 + Math.floor(rnd() * 3);
const brokenIdx = new Set();
while (brokenIdx.size < nBroken) brokenIdx.add(1 + Math.floor(rnd() * n));
let paidOrders = 0, revenue = 0;
const broken = [];
for (let i = 1; i <= n; i++) {
  const id = 1000 + i;
  const items = Array.from({ length: 1 + Math.floor(rnd() * 3) }, () => {
    const [sku, price] = pick(products);
    return { sku, price, qty: 1 + Math.floor(rnd() * 3) };
  });
  const status = rnd() < 0.8 ? 'paid' : pick(['refunded', 'cancelled']);
  const order = { id: `A-${id}`, customer: pick(customers), items, status, createdAt: `2026-10-27T${String(Math.floor(rnd() * 24)).padStart(2, '0')}:00:00+09:00` };
  let text = JSON.stringify(order);
  const file = `order-${id}.json`;
  if (brokenIdx.has(i)) {
    text = text.slice(0, Math.floor(text.length * (0.3 + rnd() * 0.5)));  // 저장 중 잘린 파일
    broken.push(file);
  } else if (status === 'paid') {
    paidOrders += 1;
    for (const it of items) revenue += it.price * it.qty;
  }
  fs.writeFileSync(path.join(dir, file), text);
}
fs.writeFileSync('/opt/cmdlab/secret/expected.json', JSON.stringify({ paidOrders, revenue, broken: broken.sort() }));
JS
cat > "$H/tools/summary.js" <<'JS'
#!/usr/bin/env node
// 주문 파일(~/orders/*.json)을 모아 매출 요약(~/report/summary.json)을 만든다.
const fs = require('fs');
const path = require('path');
const os = require('os');

const dir = path.join(os.homedir(), 'orders');
const outDir = path.join(os.homedir(), 'report');

let paidOrders = 0;
let revenue = 0;

for (const file of fs.readdirSync(dir)) {
  const order = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
  paidOrders += 1;
  for (const item of order.items) {
    revenue += item.price * item.qty;
  }
}

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'summary.json'), JSON.stringify({ paidOrders, revenue }, null, 2) + '\n');
console.log(`주문 ${paidOrders}건, 매출 ${revenue.toLocaleString()}원`);
JS
give "$H/tools" "$H/orders"
