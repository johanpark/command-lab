`cat ~/request.txt` 로 주문 번호를 확인하고, 일반 `grep 주문번호 ~/logs/*` 를 해 보세요. `.gz` 파일은 "binary file matches" 로 나오거나 못 찾아요.
---
`zgrep 주문번호 ~/logs/*` 는 압축 파일도 풀어서 찾아 줘요. 그런데 주문 번호는 여러 줄(요청, 결제, 에러)에 나와요. `ERROR` 줄만: `zgrep 주문번호 ~/logs/* | grep ERROR`
---
파일 이름만 보려면 `zgrep -l` 이지만, 그 주문 번호가 여러 파일에 나오면 에러가 있는 파일을 골라야 해요. `zgrep ERROR ~/logs/* | grep 주문번호` 결과의 맨 앞이 파일 이름이에요.
---
문맥: `zgrep -B 2 "ERROR.*주문번호" ~/logs/파일 > ~/incident.txt` (파일을 하나만 지정하면 파일 이름 접두어가 붙지 않아요)
