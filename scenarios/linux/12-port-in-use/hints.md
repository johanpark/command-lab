`ss -ltn` 으로 지금 열려 있는 포트를 보세요. 8080 과 9100 이 보일 거예요. `p` 를 붙이면(`ss -ltnp`) 어떤 프로세스인지도 나와요.
---
다른 사용자의 프로세스는 `ss -ltnp` 에 이름이 안 보일 수 있어요. 그럴 땐 `sudo ss -ltnp` 또는 `sudo lsof -i :8080`
---
`users:(("이름",pid=123,fd=3))` 에서 이름과 PID 를 확인하세요. `echo 이름 > ~/answer.txt` 후 `sudo kill 123`
---
`ss -ltnp` 로 8080 이 비었는지 확인하고 `~/myapp/start.sh`. 마지막으로 `ss -ltnp` 에서 8080 을 `myapp` 이 쓰고 있는지 확인!
