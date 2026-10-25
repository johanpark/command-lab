# 해설

```bash
ps aux --sort=-%cpu | head -n 5
# USER   PID %CPU %MEM ... COMMAND
# learner 42 99.8  0.0 ... /bin/bash /usr/local/bin/data-sync
pgrep -a data-sync          # 42 /bin/bash /usr/local/bin/data-sync
kill 42
echo data-sync > ~/answer.txt
ps aux --sort=-%cpu | head  # 사라졌는지 확인
```

## 다른 방법
```bash
pkill -x data-sync          # 이름으로 바로 종료 (-x: 이름이 정확히 일치하는 것만)
```
⚠️ `pkill sync` 처럼 일부만 쓰면 이름에 sync 가 들어간 **다른 프로세스까지** 죽일 수 있어요. 실무에서는 `pgrep` 으로 대상을 먼저 확인한 뒤 종료하세요.

## kill 신호
| 명령 | 의미 |
|---|---|
| `kill PID` (= `kill -15`) | "정리하고 종료해 주세요" (기본, 우선 이걸로) |
| `kill -9 PID` | 강제 종료. 정리할 기회를 주지 않으므로 최후의 수단 |

## top 단축키
`P` CPU순 · `M` 메모리순 · `k` 프로세스 종료 · `1` CPU 코어별 보기 · `q` 종료
