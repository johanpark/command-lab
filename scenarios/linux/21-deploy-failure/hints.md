`ls -lt ~/app/logs` 로 로그 파일을 최근 수정 순으로 보세요. `app.log.1` 은 **어제** 로그예요. 지금 실패와는 상관없는 에러가 섞여 있으니 속지 마세요.
---
`tail -n 20 ~/app/logs/app.log` 에서 `FATAL` 줄을 보세요. 첫 번째 원인은 설정 파일을 **읽을 권한**이 없는 거예요. `ls -l ~/app/config/app.env` 로 소유자를 확인하고, `sudo chown learner:learner ~/app/config/app.env` 로 고칠 수 있어요.
---
다시 `./deploy.sh` → 다시 `tail ~/app/logs/app.log`. 이번엔 PORT 값이 숫자가 아니래요. `cat -A ~/app/config/app.env` 로 보면 `9OOO` 처럼 숫자 0 대신 **알파벳 O** 가 들어간 게 보일 거예요.
---
`nano ~/app/config/app.env` 로 고치고 다시 배포. 그다음 에러(DOC_ROOT)도 같은 방식으로 로그를 읽고 경로를 `ls` 로 확인해서 고치면 됩니다.
