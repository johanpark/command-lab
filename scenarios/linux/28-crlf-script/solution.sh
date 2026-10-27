cd ~/deploy
grep -rl $'\r' --include='*.sh' . | xargs sed -i 's/\r$//'
./deploy.sh
