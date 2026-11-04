# 설명: try/catch 없이 JSON.parse 하면 깨진 파일 하나에 스크립트 전체가 멈춘다
# 실패해야: 멈추지 않고 끝까지
cat > ~/tools/summary.js <<'JS'
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const os = require('os');

const dir = path.join(os.homedir(), 'orders');
const outDir = path.join(os.homedir(), 'report');

let paidOrders = 0;
let revenue = 0;
const broken = [];

for (const file of fs.readdirSync(dir).filter((f) => f.endsWith('.json'))) {
  const order = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
  if (order.status !== 'paid') continue;
  paidOrders += 1;
  for (const item of order.items) revenue += item.price * item.qty;
}

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'summary.json'), JSON.stringify({ paidOrders, revenue, broken: broken.sort() }, null, 2) + '\n');
console.log(`주문 ${paidOrders}건, 매출 ${revenue.toLocaleString()}원, 깨진 파일 ${broken.length}개`);
JS
node ~/tools/summary.js || true
