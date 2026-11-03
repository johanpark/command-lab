# 설명: app-restart 와 함께 vim·tee 를 허용하면 그걸로 root 를 얻을 수 있다
# 실패해야: app-restart 하나뿐
echo 'deploy ALL=(root) NOPASSWD: /usr/local/bin/app-restart, /usr/bin/vim.tiny, /usr/bin/tee' > /tmp/d
sudo install -m 0440 /tmp/d /etc/sudoers.d/deploy
