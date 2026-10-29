# 새 EC2 에서 앱이 안 떠요 (user-data 로그)

트래픽이 늘어서 오토스케일링이 서버를 한 대 더 띄웠어요. 그런데 이 서버만 **헬스 체크에 실패**해서 로드밸런서가 손님을 안 보내고 있어요.

EC2 는 처음 켜질 때 **user-data** 라는 부팅 스크립트를 한 번 실행해요. (앱 설치, 설정, 시작) 이 일은 **cloud-init** 이 맡고, 그 출력은 로그 파일에 남아요.

| 파일 | 내용 |
|---|---|
| `/var/log/cloud-init-output.log` | user-data 스크립트의 출력 (에러도 여기) |
| `/var/lib/cloud/instance/user-data.txt` | 이번에 실행된 user-data 스크립트 |
| `~/runbook.md` | 운영 문서 (설정값) |

## 목표
1. 부팅 스크립트를 **멈추게 한 변수 이름**을 `~/answer.txt` 에 저장하세요.
2. 스크립트가 **멈춘 곳부터 남은 단계를 마무리**해서 앱을 띄우세요.
   - 앱이 `http://localhost:8080/health` 에서 `ok` 를 돌려줘야 해요.
   - 앱은 **`shop` 사용자**로 실행돼야 해요. (root 로 띄우면 안 돼요)
3. 다음에 뜨는 서버는 같은 문제가 없도록 **`/var/lib/cloud/instance/user-data.txt` 를 고치세요.** (런치 템플릿에 반영할 수정본)

관리 명령은 `sudo` 를 쓰세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `sudo tail -n 30 /var/log/cloud-init-output.log` | 로그 끝부분 |
| `grep -n 'error\|Error\|unbound' 파일` | 에러 줄과 줄 번호 |
| `cat -n 파일` | 줄 번호 붙여 보기 |
| `sudo -u shop 명령` | shop 사용자로 실행 |
| `ps -o user,pid,cmd -C busybox` | 누가 실행 중인지 |
| `curl -s localhost:8080/health` | 헬스 체크 |
