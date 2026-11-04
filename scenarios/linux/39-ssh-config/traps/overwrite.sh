# 설명: config 를 새로 써서 덮으면 bastion·공통 설정이 사라지고, 권한도 666 그대로다
# 실패해야: bastion 별칭
# 실패해야: ServerAliveInterval
# 실패해야: 다른 사람이 쓸 수 없다
awk 'NR > 1 { printf "Host %s\n    HostName %s\n    User %s\n    Port %s\n    IdentityFile %s\n\n", $1, $2, $3, $4, $5 }' ~/servers.txt > ~/.ssh/config
