sudo useradd -m -s /bin/bash kim
sudo groupadd webdev
sudo usermod -aG webdev learner
sudo usermod -aG webdev kim
sudo chgrp webdev /srv/website
sudo chmod 2770 /srv/website
