# 설명: ALL 을 주고 cat·bash 만 빼는 건 막은 게 아니다
# 실패해야: app-restart 하나뿐
# 실패해야: /etc/sudoers.d/deploy 에 있다
echo 'deploy ALL=(root) NOPASSWD: ALL, !/usr/bin/cat, !/bin/cat, !/usr/bin/bash, !/bin/bash' > /tmp/d
sudo install -m 0440 /tmp/d /etc/sudoers.d/deploy
