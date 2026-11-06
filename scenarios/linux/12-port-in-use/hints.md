`ss -ltn` 으로 지금 열려 있는 포트를 보세요. 8080 과 9100 이 보일 거예요. `p` 를 붙이면(`ss -ltnp`) 어떤 프로세스인지도 나오는데…
---
프로세스 칸이 비어 있나요? 다른 사용자(root)의 프로세스라서 그래요. `sudo ss -ltnp` 로 보세요. (`netstat -ltnp` 도 같은 정보를 보여 주지만 마찬가지로 `sudo` 가 필요해요)
---
`users:(("이름",pid=123,fd=3))` 에서 이름과 PID 를 확인하세요. `lsof` 나 `top` 은 긴 이름을 잘라서(`old-gatew`) 보여 주니, 이름은 `ss` 나 `ps -p 123 -o comm` 으로 확인하세요. `echo 이름 > ~/answer.txt` 후 `sudo kill 123`
---
`ss -ltn` 으로 8080 이 비었는지 확인하고 `~/myapp/start.sh`. 마지막으로 `ss -ltnp` 에서 8080 을 `myapp` 이 쓰고 있는지 확인!
