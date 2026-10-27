# 팀 공유 폴더 만들기

새 팀원 **kim** 이 들어왔습니다. 웹사이트 소스가 있는 `/srv/website` 폴더를 나(learner)와 kim 이 **함께 수정**할 수 있게 해 주세요. 다른 사람은 들어오면 안 됩니다.

## 목표
1. 사용자 **`kim`** 을 만드세요. 홈 폴더(`/home/kim`)가 있어야 하고, 셸은 `/bin/bash`.
2. 그룹 **`webdev`** 를 만들고 **learner 와 kim** 을 넣으세요.
   ⚠️ learner 는 이미 `designers` 그룹에도 속해 있어요. **거기서 빠지면 안 됩니다.**
3. `/srv/website` 의 그룹을 `webdev` 로 바꾸고, 권한을 **소유자와 그룹은 모두 가능(rwx), 다른 사람은 아무것도 못 함**으로.
4. 이 폴더 안에 새로 만드는 파일도 **자동으로 webdev 그룹**이 되도록 설정하세요. (setgid)

모두 관리자 권한이 필요해요. 명령 앞에 `sudo` 를 붙이세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `sudo useradd -m -s /bin/bash 이름` | 사용자 만들기 (`-m` 홈 폴더 생성) |
| `sudo groupadd 그룹` | 그룹 만들기 |
| `sudo usermod -aG 그룹 사용자` | 사용자를 그룹에 **추가** |
| `id 사용자`, `getent group 그룹` | 소속 그룹 확인 |
| `sudo chgrp 그룹 폴더` | 그룹 바꾸기 |
| `sudo chmod 2770 폴더` | 권한 + setgid (맨 앞 2) |
