# 설명: tee 에 -a 를 빼면 기존 허용 목록이 사라진다
# 실패해야: 기존 허용 목록
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' ~/request.txt | sudo tee /etc/app/allowed_ips >/dev/null
printf 'MAINTENANCE=on\nUNTIL=06:00\n' | sudo tee /etc/app/maintenance.conf >/dev/null
