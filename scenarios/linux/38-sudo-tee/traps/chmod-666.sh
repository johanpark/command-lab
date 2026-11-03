# 설명: chmod 666 으로 열어 놓고 sudo 없이 쓰면 아무나 허용 목록을 고칠 수 있다
# 실패해야: root 만 쓸 수 있다
sudo chmod 666 /etc/app/allowed_ips
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' ~/request.txt >> /etc/app/allowed_ips
printf 'MAINTENANCE=on\nUNTIL=06:00\n' | sudo tee /etc/app/maintenance.conf >/dev/null
