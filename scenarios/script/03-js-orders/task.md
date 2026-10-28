# 깨진 JSON 이 섞인 주문 집계 (Node.js)

쇼핑몰이 주문 한 건마다 `~/orders/order-XXXX.json` 파일을 남겨요. 매일 아침 `~/tools/summary.js` 가 이걸 모아 매출 요약 `~/report/summary.json` 을 만들어요. 그런데 오늘은 이렇게 멈췄어요.

```
$ node ~/tools/summary.js
undefined:1
{"id": "A-1042", "customer": "kim", "items": [{"sku": "KB-01", "pri
SyntaxError: Unexpected end of JSON input
```

서버가 저장 도중 꺼지면서 **몇몇 파일이 잘렸대요.** 파일 하나 때문에 전체 보고서가 안 나오면 안 되겠죠.

## 목표
`~/tools/summary.js` 를 고쳐서 실행하세요. 결과 `~/report/summary.json` 은 이런 모양이어야 해요.
```json
{
  "paidOrders": 123,
  "revenue": 45678900,
  "broken": ["order-1042.json", "order-1077.json"]
}
```
1. `paidOrders`: 상태(`status`)가 **`paid`** 인 주문 수 (`refunded`, `cancelled` 는 빼요)
2. `revenue`: paid 주문의 매출 합계 (각 상품 `price × qty` 의 합)
3. `broken`: 읽을 수 없는 **파일 이름** 목록 (이름 순 정렬)
4. 깨진 파일이 있어도 **멈추지 말고** 나머지는 집계하세요.

> 채점할 때 `summary.json` 을 지우고 **스크립트를 다시 실행**해 봐요. 결과 파일만 손으로 만들면 통과 못 해요!

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `node ~/tools/summary.js` | 실행 |
| `cat ~/tools/summary.js` / `nano ...` | 읽기 / 고치기 |
| `node` | 대화형 Node.js (`.exit` 로 종료) |
| `ls ~/orders \| head`, `cat ~/orders/order-1001.json` | 데이터 구경 |
| `jq . ~/orders/파일.json` | JSON 이 올바른지 확인 (깨졌으면 에러) |

## JavaScript 한 줄 사전
| 코드 | 뜻 |
|---|---|
| `try { ... } catch (e) { ... }` | 에러가 나도 멈추지 않고 catch 로 |
| `JSON.parse(text)` | 문자열 → 객체 (잘못되면 에러를 **던짐**) |
| `arr.push(x)` / `arr.sort()` | 배열에 넣기 / 정렬 |
| `continue` | 반복문에서 이번 차례 건너뛰기 |
