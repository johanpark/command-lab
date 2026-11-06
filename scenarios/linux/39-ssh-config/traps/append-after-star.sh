# 설명: Host * 아래(파일 끝)에 붙이면 먼저 나온 Host * 의 User admin 이 이긴다
# 실패해야: ssh web 설정이 맞다
awk 'NR > 1 { printf "\nHost %s\n    HostName %s\n    User %s\n    Port %s\n    IdentityFile %s\n", $1, $2, $3, $4, $5 }' ~/servers.txt >> ~/.ssh/config
chmod 600 ~/.ssh/config
