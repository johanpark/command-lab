# 해설

```bash
ls -lt ~/app/logs                      # app.log 가 방금 바뀜, app.log.1 은 어제 것
tail -n 5 ~/app/logs/app.log
# FATAL cannot read config ...: Permission denied
ls -l ~/app/config/app.env             # -rw------- root root
sudo chown learner:learner ~/app/config/app.env
./deploy.sh && tail -n 3 ~/app/logs/app.log
# FATAL invalid PORT value '9OOO'
cat -A ~/app/config/app.env            # 눈으로는 9000 과 9OOO 가 구분이 안 돼요
nano ~/app/config/app.env              # PORT=9000
./deploy.sh && tail -n 3 ~/app/logs/app.log
# FATAL DOC_ROOT does not exist: /home/learner/app/publc
ls ~/app                               # public 이 맞음
nano ~/app/config/app.env              # DOC_ROOT=/home/learner/app/public
./deploy.sh                            # ✅ 배포 성공
curl -i http://localhost:9000/health
```

## 장애 대응에서 배울 것
- **최근 로그부터**: 어제 로그(`app.log.1`)의 `database timeout` 은 그럴듯하지만 지금 장애와 상관없어요. `ls -lt` 로 수정 시각을 보고, `tail` 로 **끝부분**을 보는 습관.
- **한 번에 하나씩**: 원인 하나 고치기 → 재시도 → 다음 에러. 여러 개를 한꺼번에 바꾸면 무엇이 효과가 있었는지 알 수 없어요.
- **권한은 필요한 만큼만**: `chmod 777` 은 "일단 되게"는 하지만, 설정(비밀번호가 들어 있을 수 있음)을 누구나 고칠 수 있게 만듭니다. 소유자를 맞추는(`chown`) 게 정석이에요.
- **보이지 않는 오타**: `0`/`O`, `l`/`1`, 공백, 탭, Windows 줄바꿈(`^M`)... `cat -A` 는 숨은 문자까지 보여줘요.

## 실제 서버에서는
| 여기서 | 실제 서버에서 흔한 것 |
|---|---|
| `tail ~/app/logs/app.log` | `journalctl -u 서비스 -n 50 -f`, `kubectl logs` |
| `./deploy.sh` | `systemctl restart 서비스`, CI/CD 파이프라인 |
| `curl /health` | 로드밸런서·쿠버네티스의 헬스 체크 |
