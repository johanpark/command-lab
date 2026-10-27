# 해설

```bash
sudo useradd -m -s /bin/bash kim
sudo groupadd webdev
sudo usermod -aG webdev learner
sudo usermod -aG webdev kim
sudo chgrp webdev /srv/website
sudo chmod 2770 /srv/website
ls -ld /srv/website        # drwxrws--- root webdev
id learner                 # ... designers, webdev
```

## 함정 포인트: `-aG`
`usermod -G webdev learner` 는 "learner 의 보조 그룹을 webdev **로 바꿔라**"예요. 원래 있던 designers 에서 빠집니다. 실제 서버에서 이 실수로 sudo/docker 그룹에서 빠져 권한을 잃는 사고가 자주 나요. **항상 `-aG`**.

## 그룹 변경이 바로 안 보일 때
그룹은 **로그인할 때** 정해집니다. 지금 열린 셸에서 `id` 를 치면 webdev 가 안 보일 수 있어요. 다시 로그인하거나 `newgrp webdev` 로 반영하세요.

## 특수 권한 정리
| 숫자 | 이름 | 폴더에 걸면 |
|---|---|---|
| 4 | setuid | (폴더에는 의미 없음) |
| 2 | **setgid** | 새로 만든 파일이 **폴더의 그룹**을 물려받음 → 팀 공유 폴더에 필수 |
| 1 | sticky | 남의 파일은 못 지움 (`/tmp` 가 이것: `drwxrwxrwt`) |
