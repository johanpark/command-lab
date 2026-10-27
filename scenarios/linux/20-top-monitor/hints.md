`top` 을 실행하고 5~10초 지켜보세요. 맨 위로 올라왔다 내려갔다 하는 프로세스가 있을 거예요. `P` 를 누르면 CPU 순으로 정렬돼요.
---
메모리는 `top` 에서 `M` 을 누르면 RES(실제 사용 메모리) 순으로 바뀌어요. `ps aux --sort=-rss | head -n 5` 로도 확인할 수 있어요.
---
CPU 가 튀는 순간을 놓쳤다면 배치 모드로 여러 번 찍어 보세요: `top -b -n 5 -d 1 | grep -A 3 PID`
---
`echo 이름 > ~/cpu.txt`, `echo 이름 > ~/mem.txt`, 그리고 `top -b -n 1 > ~/top-report.txt`
