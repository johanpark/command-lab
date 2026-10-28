# 해설

```bash
cat ~/request.txt                                  # ORD-123456
zgrep ORD-123456 ~/logs/*                          # 여러 파일에 나옴 (생성, 조회, 에러)
zgrep -l "ERROR.*ORD-123456" ~/logs/*              # 에러가 있는 파일만
zgrep -B 2 "ERROR.*ORD-123456" ~/logs/app.log.3.gz > ~/incident.txt
cat ~/incident.txt
# ... INFO  [order] created ORD-123456 user=u4821 amount=45000
# ... WARN  [payment] gateway retry 2/3 for ORD-123456: card declined: expired card
# ... ERROR [payment] payment failed ORD-123456 after 3 attempts
```

## z 로 시작하는 친구들
| 명령 | 압축 안 된 버전 |
|---|---|
| `zcat` | `cat` |
| `zgrep` | `grep` |
| `zless` | `less` |
| `zdiff` | `diff` |
`.bz2` 는 `bzgrep`, `.xz` 는 `xzgrep` 이 있어요.

## 문맥 옵션
- `-B N` (Before), `-A N` (After), `-C N` (Context, 앞뒤 모두)
- 여러 결과 사이에는 `--` 구분선이 들어가요.
- 에러 한 줄만 보면 "결제 실패"뿐이지만, **바로 앞 줄**에 진짜 원인(카드 만료)이 있는 경우가 정말 많아요.

## 로그 순환(logrotate)
리눅스는 보통 `logrotate` 가 매일/매주 `app.log` → `app.log.1` → `app.log.2.gz` ... 로 밀어내고 오래된 건 지워요. 며칠 전 일을 찾을 땐 **압축된 파일까지** 보는 습관!
