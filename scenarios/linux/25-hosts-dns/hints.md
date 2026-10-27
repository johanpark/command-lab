`curl -v -m 3 http://api.internal:8000/health` 의 `Trying ...` 줄을 보세요. 어느 IP 로 접속하려고 하나요? `getent hosts api.internal` 로도 확인할 수 있어요.
---
리눅스는 이름을 찾을 때 DNS 보다 **`/etc/hosts` 를 먼저** 봐요. `cat /etc/hosts` 에 `api.internal` 이 적혀 있지 않나요?
---
옛 서버 IP 가 그대로 남아 있어요. 그 IP 를 `echo IP > ~/answer.txt` 로 저장하고, `sudo nano /etc/hosts` 로 그 줄의 IP 를 `127.0.0.1` 로 바꾸세요.
---
⚠️ 컨테이너에서는 `sudo sed -i ... /etc/hosts` 가 "Device or resource busy" 로 실패할 수 있어요 (파일이 특별하게 연결돼 있어서). 편집기로 고치거나, 내용을 만들어서 `sudo tee /etc/hosts` 로 덮어쓰세요.
