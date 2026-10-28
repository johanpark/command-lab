# 해설

Node.js 로:
```js
// node collect.mjs
const base = 'http://localhost:8080';
let url = '/api/users?per_page=50';
const all = [];
while (url) {
  const res = await fetch(base + url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const body = await res.json();
  all.push(...body.data);
  url = body.next;              // 마지막 페이지면 null
}
const fs = await import('node:fs');
fs.writeFileSync(process.env.HOME + '/users.json', JSON.stringify(all, null, 2));
fs.writeFileSync(process.env.HOME + '/answer.txt', all.filter((u) => u.active).length + '\n');
```

## 페이지네이션 방식들
| 방식 | 모양 | 다음 페이지 |
|---|---|---|
| 번호 | `?page=2&per_page=50` | `page` 를 1씩 올리다 빈 결과가 오면 끝 |
| 다음 링크 | 응답에 `next` 주소 | 이번 문제처럼 `null` 일 때까지 따라가기 |
| 커서 | `?cursor=eyJpZCI6MTIzfQ` | 응답의 `next_cursor` 를 그대로 넘기기 (데이터가 바뀌어도 안전) |
| Link 헤더 | `Link: <...>; rel="next"` | GitHub API 방식. `curl -I` 로 헤더 확인 |

## 실무에서 챙길 것
- **total 과 개수 비교**: 다 받았는지 마지막에 확인하는 습관
- **요청 속도 제한**: 너무 빨리 부르면 `429 Too Many Requests`. 응답의 `Retry-After` 만큼 기다렸다 다시
- **에러 처리**: `res.ok` 가 아니면 멈추기. 중간 페이지가 빠진 채로 저장하면 더 큰 문제
- 같은 일을 매일 한다면 스크립트로 만들어 cron 에 등록하세요. (Python · Node.js 의 cron 시나리오 참고)
