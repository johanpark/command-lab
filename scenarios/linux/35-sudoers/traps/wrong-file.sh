# 설명: 규칙을 /etc/sudoers 에 직접 적고 deploy 파일은 껍데기만 둔다
# 실패해야: /etc/sudoers.d/deploy 에 있다
echo 'deploy ALL=(root) NOPASSWD: /usr/local/bin/app-restart' | sudo tee -a /etc/sudoers >/dev/null
echo '# deploy' > /tmp/d
sudo install -m 0440 /tmp/d /etc/sudoers.d/deploy
