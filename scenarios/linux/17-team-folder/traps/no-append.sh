# 설명: usermod 에 -a 를 빼면 learner 가 designers 그룹에서 빠진다
# 실패해야: designers
sudo useradd -m -s /bin/bash kim
sudo groupadd webdev
sudo usermod -G webdev learner
sudo usermod -aG webdev kim
sudo chgrp webdev /srv/website
sudo chmod 2770 /srv/website
