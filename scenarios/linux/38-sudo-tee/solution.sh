grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' ~/request.txt | sudo tee -a /etc/app/allowed_ips > /dev/null
printf 'MAINTENANCE=on\nUNTIL=06:00\n' | sudo tee /etc/app/maintenance.conf > /dev/null
