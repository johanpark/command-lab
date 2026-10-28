깨진 파일 찾기: `for f in ~/orders/*.json; do jq -e . "$f" >/dev/null 2>&1 || echo "$f"; done`. 이 파일들 때문에 `JSON.parse` 가 에러를 던지고 스크립트가 통째로 멈춰요.
---
`JSON.parse` 를 `try ... catch` 로 감싸세요. 에러가 나면 파일 이름을 `broken` 배열에 넣고 `continue`:
```js
let order;
try {
  order = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
} catch (e) {
  broken.push(file);
  continue;
}
```
---
지금 스크립트는 **모든 주문**을 더하고 있어요. `if (order.status !== 'paid') continue;` 로 paid 만 남기세요. 매출은 상품마다 `item.price * item.qty` 의 합이에요.
---
결과: `broken.sort()` 해서 `{ paidOrders, revenue, broken }` 을 `JSON.stringify(결과, null, 2)` 로 저장. `~/report` 폴더가 없으면 `fs.mkdirSync(..., { recursive: true })`. 끝나면 `cat ~/report/summary.json`!
