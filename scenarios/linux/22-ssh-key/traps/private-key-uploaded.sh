# 설명: 개인키를 authorized_keys 에 넣으면 안 된다 (공개키가 아니라)
# 실패해야: 개인키가 들어가 있지 않다
# 실패해야: 내 공개키가 deploy 의
ssh-keygen -q -t ed25519 -C "learner@lab" -N "" -f ~/.ssh/id_ed25519
sudo mkdir -p /home/deploy/.ssh
cat ~/.ssh/id_ed25519 | sudo tee /home/deploy/.ssh/authorized_keys > /dev/null
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
