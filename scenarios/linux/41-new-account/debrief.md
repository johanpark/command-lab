# 해설

```bash
u=minji   # 요청서의 계정
sudo useradd -m -s /bin/bash -G developers "$u"
sudo install -d -m 700 -o "$u" -g "$u" /home/$u/.ssh
sudo install -m 600 -o "$u" -g "$u" ~/onboarding/$u.pub /home/$u/.ssh/authorized_keys
sudo usermod -aG deploy jun
id "$u"; id jun
```

## useradd 의 기본값 함정
| 빠뜨린 옵션 | 결과 |
|---|---|
| `-m` | 홈 폴더가 없음 → 로그인해도 `/` 에 떨어짐 |
| `-s /bin/bash` | 셸이 `/bin/sh` → 자동완성·히스토리가 안 됨 |
| `-G` | 보조 그룹 없음 |

Ubuntu/Debian 에는 대화형으로 물어보며 만들어 주는 `adduser` 도 있어요. 스크립트에서는 옵션이 분명한 `useradd` 를 많이 써요.

## usermod -G 사고
`-G` 는 보조 그룹 목록을 **통째로 바꿔요.** `-a`(append) 를 붙여야 추가예요. 운영 서버에서 이 실수로 sudo 그룹이 빠져 관리자가 잠기는 사고가 자주 나요. 바꾼 뒤에는 꼭 `id 계정` 으로 확인하세요. (이미 로그인한 사용자는 **다시 로그인해야** 새 그룹이 적용돼요)

## sshd 가 키를 무시하는 이유 (StrictModes)
`authorized_keys` 나 `.ssh`, 홈 폴더가 다른 사람도 쓸 수 있거나 **다른 사용자 소유**면, sshd 는 누가 키를 몰래 넣었을 수 있다고 보고 그 파일을 무시해요. 증상은 "키를 넣었는데 비밀번호를 물어봐요". 서버 쪽 `/var/log/auth.log` 에 `Authentication refused: bad ownership or modes` 가 남아요.

## 계정 정리할 때
퇴사자는 `sudo usermod -L 계정` (잠금) 또는 `sudo userdel -r 계정` (홈까지 삭제). 지우기 전에 홈 폴더 백업과 crontab(`sudo crontab -u 계정 -l`) 확인을 잊지 마세요.
