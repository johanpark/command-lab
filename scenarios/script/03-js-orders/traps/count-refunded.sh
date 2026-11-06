# 설명: cancelled 만 빼면 refunded 주문까지 매출에 들어간다
# 실패해야: paidOrders
# 실패해야: revenue
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
  let order;
  try {
    order = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
  } catch (e) {
    broken.push(file);
    continue;
  }
  if (order.status === 'cancelled') continue;
  paidOrders += 1;
  for (const item of order.items) revenue += item.price * item.qty;
}

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'summary.json'), JSON.stringify({ paidOrders, revenue, broken: broken.sort() }, null, 2) + '\n');
console.log(`주문 ${paidOrders}건, 매출 ${revenue.toLocaleString()}원, 깨진 파일 ${broken.length}개`);
JS
node ~/tools/summary.js
