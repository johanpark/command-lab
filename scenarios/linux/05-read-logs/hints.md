먼저 `head ~/logs/app.log` 로 로그가 어떻게 생겼는지 보세요. 각 줄에 `INFO`, `WARN`, `ERROR` 같은 레벨이 있어요.
---
`grep ERROR ~/logs/app.log` 로 에러 줄만 볼 수 있어요. 이 출력을 `> ~/errors.log` 로 저장하면 3번 완료.
---
개수는 `grep -c ERROR 파일` 또는 `grep ERROR 파일 | wc -l`. 주의: 메시지 안에 `error` (소문자)가 들어간 INFO 줄도 있어요. 대문자 `ERROR` 만 세야 해요.
---
`grep -c ERROR ~/logs/app.log > ~/answer.txt` 와 `tail -n 20 ~/logs/app.log > ~/recent.log`
