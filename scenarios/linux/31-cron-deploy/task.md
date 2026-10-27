# 손으로는 되는데 cron 에선 실패해요

`~/deploy/nightly.sh` 는 매일 밤 cron 으로 실행되는 배포 스크립트예요. 직접 실행하면 잘 되는데:

```
$ cd ~/deploy && ./nightly.sh
✅ 야간 배포 완료
```

cron 으로 돌면 매번 실패합니다. cron 이 남긴 로그 `~/deploy/cron.log` 를 보세요.

## 목표
`nightly.sh` 를 고쳐서 cron 처럼 **어느 폴더에서든, 최소한의 환경(짧은 PATH)으로** 실행해도 성공하게 하세요. 아래 명령이 성공하면 돼요.
```bash
cd / && env -i HOME=$HOME PATH=/usr/bin:/bin bash ~/deploy/nightly.sh
```
- 성공하면 `~/site/build.txt` 에 오늘 날짜가 찍혀요.
- 파일들(`config/`, `dist/`, `~/.local/bin/notify`)을 다른 곳으로 옮기지 말고 **스크립트를 고치세요.**

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `cat ~/deploy/cron.log` | cron 실행 기록 |
| `env -i 변수=값 ... 명령` | 환경 변수를 거의 비운 상태로 실행 (cron 흉내) |
| `"$(dirname "$0")"` | 스크립트 파일이 있는 폴더 |
| `which 명령` / `command -v 명령` | 명령이 어디 있는지 |
