# 해설

```js
#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const os = require('os');

const dir = path.join(os.homedir(), 'orders');
const outDir = path.join(os.homedir(), 'report');

let paidOrders = 0, revenue = 0;
const broken = [];

for (const file of fs.readdirSync(dir).filter((f) => f.endsWith('.json'))) {
  let order;
  try {
    order = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
  } catch (e) {
    broken.push(file);                           // 기록하고 넘어가기
    continue;
  }
  if (order.status !== 'paid') continue;
  paidOrders += 1;
  for (const item of order.items) revenue += item.price * item.qty;
}

fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(path.join(outDir, 'summary.json'),
  JSON.stringify({ paidOrders, revenue, broken: broken.sort() }, null, 2) + '\n');
if (broken.length) console.error(`⚠️ 깨진 파일 ${broken.length}개: ${broken.join(', ')}`);
```

## 배치 작업의 원칙: 하나 때문에 전체가 멈추지 않게
- **잡을 수 있는 에러는 잡고, 반드시 기록**하세요. 조용히 무시하면 매출이 빠진 걸 아무도 몰라요.
- 반대로 "설정 파일이 없다"처럼 계속해 봐야 의미 없는 에러는 바로 멈추는 게 맞아요.
- 깨진 데이터가 있었다는 걸 cron 이나 모니터링이 알 수 있게 `process.exitCode = 1` 로 끝내는 방법도 있어요.

## 파일이 잘리지 않게 쓰려면
쓰는 쪽에서 **임시 파일에 다 쓴 뒤 이름 바꾸기**를 하면 읽는 쪽은 완성된 파일만 봐요.
```js
fs.writeFileSync(file + '.tmp', data);
fs.renameSync(file + '.tmp', file);   // 같은 디스크 안에서 rename 은 한 번에 일어남
```

## 셸 + jq 로 하면?
```bash
jq -s '[.[] | select(.status == "paid")] | {paidOrders: length, revenue: ([.[].items[] | .price * .qty] | add)}' ~/orders/*.json
```
깨진 파일이 하나라도 있으면 jq 도 멈춰요. 그래서 이런 처리는 스크립트로 짜는 게 안전해요.
