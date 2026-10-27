# 해설

```bash
df -h /                      # 공간이 그대로
lsof +L1
# COMMAND        PID    USER  FD  TYPE SIZE/OFF  NLINK NAME
# payment-l…     42  learner  3w  REG  80001234     0 /var/log/shop/app.log (deleted)
ps -p 42 -o comm= > ~/answer.txt
: > /proc/42/fd/3            # 내용만 비우기 (프로세스는 계속 씀)
lsof +L1                     # SIZE 가 거의 0
```

## 왜 이런 일이?
리눅스에서 `rm` 은 파일의 **이름(링크)** 을 지우는 거예요. 내용(inode)은 이름도 없고 **열고 있는 프로세스도 없을 때** 비로소 해제됩니다. 그래서 `du`(이름 기준)와 `df`(실제 사용량 기준)가 다르게 나오는 거예요.

## 해결 방법 비교
| 방법 | 장점 | 단점 |
|---|---|---|
| 프로세스 재시작 | 깔끔함 | 서비스가 잠깐 멈춤 |
| `: > /proc/PID/fd/N` | **무중단** | 그 로그 내용은 사라짐 |

## 다음부터는
- 쓰고 있는 로그를 줄일 땐 `rm` 대신 **`: > 파일`** (truncate) 을 쓰세요. 파일을 연 프로세스도 그대로 쓸 수 있어요.
- 로그는 `logrotate` 로 관리하면, 순환 후 프로세스에 "다시 열어" 신호를 보내 줘요.
