`sudo tail -n 30 /var/log/cloud-init-output.log` 의 끝에 `unbound variable` 이 보여요. 스크립트 맨 위의 `set -u` 는 **값이 없는 변수를 쓰면 바로 멈추라**는 뜻이에요. `+` 로 시작하는 줄은 `set -x` 가 찍은 "실행한 명령" 이라서, 어디까지 실행됐는지 알 수 있어요.
---
`cat -n /var/lib/cloud/instance/user-data.txt` 와 로그를 비교해 보세요. 멈춘 줄 **이후의 명령들은 실행되지 않았어요.** 그 변수 값은 `~/runbook.md` 에 있어요.
---
남은 단계를 직접 하면 돼요: 설정 파일(`/opt/shop/config/app.env`)의 `DB_HOST=` 줄에 runbook 의 값을 넣고 (`sudo sed -i 's/^DB_HOST=.*/DB_HOST=값/' ...` 또는 `sudo nano`), 그다음 스크립트의 나머지 줄(`chown ...`, `sudo -u shop ...start.sh`)을 차례로 실행.
---
다음 서버를 위해: user-data 스크립트에서 그 변수를 쓰기 **전에** 값을 정하세요. 예: `set -euxo pipefail` 다음 줄에 `DB_HOST=prod-db.internal` (실제로는 SSM Parameter Store 에서 읽어 오는 게 좋아요 → 해설). 고친 뒤 `bash -n 파일` 로 문법 확인!
