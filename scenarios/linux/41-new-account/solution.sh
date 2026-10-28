u=$(grep -oP '계정: \K\S+' ~/onboarding/request.txt)
sudo useradd -m -s /bin/bash -G developers "$u"
sudo install -d -m 700 -o "$u" -g "$u" "/home/$u/.ssh"
sudo install -m 600 -o "$u" -g "$u" ~/onboarding/"$u".pub "/home/$u/.ssh/authorized_keys"
sudo usermod -aG deploy jun
id "$u"; id jun
