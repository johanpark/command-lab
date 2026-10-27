`ssh-keygen -t ed25519 -C "learner@lab"` 을 실행하고, 위치와 암호를 물으면 그냥 Enter 를 누르세요. `ls -l ~/.ssh` 로 두 파일이 생겼는지 확인!
---
deploy 의 홈은 내 것이 아니라서 `sudo` 가 필요해요: `sudo mkdir -p /home/deploy/.ssh`
---
공개키 붙이기: `cat ~/.ssh/id_ed25519.pub | sudo tee -a /home/deploy/.ssh/authorized_keys`. (`sudo cat ... >> 파일` 은 안 돼요. `>>` 는 sudo 가 아니라 내 셸이 처리하거든요)
---
sudo 로 만든 건 소유자가 root 예요: `sudo chown -R deploy:deploy /home/deploy/.ssh` → `sudo chmod 700 /home/deploy/.ssh` → `sudo chmod 600 /home/deploy/.ssh/authorized_keys`. `sudo ls -la /home/deploy/.ssh` 로 확인!
