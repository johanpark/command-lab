`top` 을 실행하고 맨 위에 있는 프로세스를 보세요. `%CPU` 열이 100에 가까운 게 범인이에요. `q` 로 나옵니다.
---
`ps aux --sort=-%cpu | head -n 5` 도 같은 정보를 보여줘요. 맨 오른쪽 COMMAND 열에 프로그램 이름이 있어요.
---
두 번째 열이 PID(프로세스 번호)예요. `kill PID번호` 로 종료합니다. `pgrep -a 이름` 으로 PID를 찾을 수도 있어요.
---
`kill` 하고 나서 `ps aux --sort=-%cpu | head` 로 정말 사라졌는지, web-server 와 log-shipper 는 살아 있는지 꼭 확인하세요.
