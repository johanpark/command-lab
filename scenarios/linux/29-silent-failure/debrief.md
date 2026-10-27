# 해설

```bash
bash -x ~/deploy.sh 2.5.0     # ls: cannot access '.../app-2.5.0.tar.gz' 인데도 계속 진행
ls ~/build                     # app-v2.4.3.tar.gz  app-v2.5.0.tar.gz  ← 'v' 가 붙어 있음
nano ~/deploy.sh
```
```bash
#!/usr/bin/env bash
set -euo pipefail
VERSION=${1:?사용법: deploy.sh <버전>}
ARTIFACT=~/build/app-v$VERSION.tar.gz
...
```

## 왜 "성공"이라고 했을까?
bash 는 기본적으로 **명령이 실패해도 다음 줄로 넘어가요.** `ls` 실패 → `tar` 실패 → `cp` 실패(복사할 게 없음) → `echo "성공"` 은 당연히 성공. 스크립트의 종료 코드는 **마지막 명령(echo)** 의 것이라 0 이 됩니다. CI/CD 도구도 이걸 성공으로 봐요.

## 배포 스크립트 첫 줄의 정석
```bash
#!/usr/bin/env bash
set -euo pipefail
```
| 옵션 | 막아 주는 사고 |
|---|---|
| `-e` | 실패를 무시하고 계속 진행 |
| `-u` | 오타 난 변수가 빈 값으로 펼쳐짐 (`rm -rf "$DEPOLY_DIR/"*` → `rm -rf /*` !) |
| `-o pipefail` | `false \| tee log` 처럼 파이프 앞쪽 실패가 묻힘 |

## 실패해도 괜찮은 명령이라면
```bash
grep -q foo file || true          # 못 찾아도 계속
if ! curl -fs "$url"; then ...    # if 안에서는 set -e 가 개입하지 않음
```
