# API 결과가 20개뿐이에요 (페이지네이션)

인사팀이 **전체 직원 명단**을 달래요. 사내 API 서버(`http://localhost:8080`)에서 받을 수 있다고 해서 호출해 봤는데...

```
$ curl -s localhost:8080/api/users | jq '.data | length'
20
```

직원은 분명 20명보다 많은데 20명만 와요. 응답을 자세히 보면 이유가 있어요.

## 목표
1. **모든 직원**을 받아서 `~/users.json` 에 **하나의 JSON 배열**로 저장하세요. (각 직원 객체는 API 가 준 그대로)
2. 그중 **재직 중**(`"active": true`)인 직원 수를 `~/answer.txt` 에 저장하세요.

`curl` + `jq` 로 해도 되고, Node.js(`fetch`)나 파이썬으로 해도 돼요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `curl -s localhost:8080/api/users \| jq` | 응답 전체를 보기 좋게 |
| `curl -s 'localhost:8080/api/users?page=2'` | 2페이지 (주소에 `?` 가 있으면 따옴표로 감싸기) |
| `jq '.data'`, `jq '.next'` | 응답에서 일부만 |
| `jq -s 'add' 파일...` | 여러 JSON 배열을 하나로 합치기 |
| `jq '[.[] \| select(.active)] \| length' 파일` | 조건에 맞는 개수 |

## Node.js 한 줄 사전
| 코드 | 뜻 |
|---|---|
| `const res = await fetch(url); const body = await res.json();` | API 호출 |
| `all.push(...body.data)` | 배열 이어 붙이기 |
| `while (url) { ... }` | 다음 주소가 없을 때까지 반복 |
