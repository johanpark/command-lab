`./long-backup.sh` 를 그냥 실행하면 터미널을 30분 동안 쓸 수 없죠. 끝에 `&` 를 붙이면 백그라운드로 돌지만, **터미널이 닫힐 때 같이 죽는 건 그대로**예요.
---
`nohup` 을 앞에 붙이면 SIGHUP 을 무시해요: `nohup ./long-backup.sh &`. 그런데 출력을 지정하지 않으면 `nohup.out` 이라는 파일에 쌓여요.
---
출력 위치까지 정하기: `cd ~/backup && nohup ./long-backup.sh > backup.log 2>&1 &`. 순서가 중요해요: `> 파일` 이 먼저, `2>&1` 이 뒤에.
---
확인: `ps -ef | grep long-backup` 으로 살아 있는지, `tail -f ~/backup/backup.log` 로 진행 상황이 쌓이는지 보세요. 실수로 그냥 실행했다면 `Ctrl+C` 로 멈추고 다시 하면 돼요.
