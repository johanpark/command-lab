한 번에 하나씩 해요. 순서는 **① kim 만들기 → ② webdev 그룹 만들고 두 사람 넣기 → ③ 폴더 그룹 바꾸기 → ④ 권한 숫자**.
시작 전에 `id learner` (지금 소속 그룹), `ls -ld /srv/website` (폴더 상태) 를 한 번 보세요.
---
**① kim 만들기**
`sudo useradd -m -s /bin/bash kim` 한 줄이면 돼요. `-m` 이 홈 폴더를, `-s` 가 셸을 정해요.
확인: `id kim`, `ls -d /home/kim`
---
**② 그룹 만들고 두 사람 넣기**
`sudo groupadd webdev` 로 그룹을 만든 뒤, 한 사람씩 넣어요.
```
sudo usermod -aG webdev learner
sudo usermod -aG webdev kim
```
⚠️ `-G` 만 쓰면 "보조 그룹을 webdev **하나로 바꿔라**" 가 돼서 learner 가 designers 에서 빠져요. 꼭 `-a` (덧붙이기) 와 같이!
확인: `id learner` 에 `designers` 와 `webdev` 가 **둘 다** 보이면 OK
---
**③ 폴더의 그룹 바꾸기**
`sudo chgrp webdev /srv/website`
확인: `ls -ld /srv/website` 의 두 번째 이름이 `webdev` 로 바뀌었나요? (`root webdev`)
---
**④ 권한 숫자 정하기**
소유자 `rwx` = 4+2+1 = **7**, 그룹 `rwx` = **7**, 기타 `---` = **0** → `770`
여기에 setgid(**2**)를 맨 앞에 붙이면 `2770`.
`sudo chmod 2770 /srv/website`
확인: `ls -ld /srv/website` 가 `drwxrws---` 면 성공! 그룹 칸의 `s` 가 setgid 표시예요.
