`cat ~/onboarding/request.txt` 로 계정 이름을 확인하고, `id jun` 으로 jun 의 지금 그룹을 미리 봐 두세요.
---
계정: `sudo useradd -m -s /bin/bash -G developers 계정`. `-m` 이 없으면 홈 폴더가 안 생기고, `-s` 가 없으면 셸이 `/bin/sh` 가 돼요. (이미 잘못 만들었다면 `sudo usermod -s /bin/bash 계정`, 홈은 `sudo mkhomedir_helper 계정` 또는 직접 만들기)
---
SSH 키: root 로 만들면 소유자가 root 가 돼요. 이렇게 하면 한 번에 깔끔해요:
```
sudo install -d -m 700 -o 계정 -g 계정 /home/계정/.ssh
sudo install -m 600 -o 계정 -g 계정 ~/onboarding/*.pub /home/계정/.ssh/authorized_keys
```
---
jun: `sudo usermod -aG deploy jun`. ⚠️ `-a` 를 빼고 `usermod -G deploy jun` 하면 jun 의 보조 그룹이 **deploy 하나로 바뀌어** developers, audit 권한을 잃어요! 끝나면 `id jun` 으로 확인.
