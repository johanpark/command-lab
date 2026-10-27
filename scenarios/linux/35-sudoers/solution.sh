echo 'deploy ALL=(root) NOPASSWD: /usr/local/bin/app-restart' > /tmp/deploy.sudoers
sudo visudo -cf /tmp/deploy.sudoers
sudo install -m 0440 -o root -g root /tmp/deploy.sudoers /etc/sudoers.d/deploy
sudo -l -U deploy
