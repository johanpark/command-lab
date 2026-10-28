먼저 지금 상태를 보세요: `sudo -l -U deploy` → "not allowed to run sudo" 라고 나올 거예요.
---
`sudo visudo -f /etc/sudoers.d/deploy` 로 새 파일을 열어 (편집기는 nano) 한 줄만 쓰세요: `deploy ALL=(root) NOPASSWD: /usr/local/bin/app-restart`. 저장하면 visudo 가 문법을 검사해 줘요.
---
권한: `sudo chmod 440 /etc/sudoers.d/deploy`. 확인: `sudo visudo -c`, `sudo -l -U deploy`
---
deploy 로 시험: `sudo -u deploy sudo -n /usr/local/bin/app-restart` (성공해야 함), `sudo -u deploy sudo -n cat /etc/shadow` (실패해야 함). 혹시 sudo 가 고장나서 아무것도 안 되면 웹의 **↺ 처음부터** 버튼(터미널에서는 `lab reset`)으로 다시 시작하세요!
