# 설명: sudo 로 만든 폴더·파일의 소유자를 deploy 로 바꾸지 않으면 sshd 가 키를 무시한다
# 실패해야: .ssh 폴더: 소유자 deploy
# 실패해야: authorized_keys: 소유자 deploy
ssh-keygen -q -t ed25519 -C "learner@lab" -N "" -f ~/.ssh/id_ed25519
sudo mkdir -p /home/deploy/.ssh
cat ~/.ssh/id_ed25519.pub | sudo tee -a /home/deploy/.ssh/authorized_keys > /dev/null
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
