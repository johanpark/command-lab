ssh-keygen -q -t ed25519 -C "learner@lab" -N "" -f ~/.ssh/id_ed25519
sudo mkdir -p /home/deploy/.ssh
cat ~/.ssh/id_ed25519.pub | sudo tee -a /home/deploy/.ssh/authorized_keys > /dev/null
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh
sudo chmod 600 /home/deploy/.ssh/authorized_keys
