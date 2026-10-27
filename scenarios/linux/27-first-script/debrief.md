# 해설

```bash
#!/usr/bin/env bash
# 사용법: backup.sh <폴더>
set -euo pipefail                      # (권장) 에러 나면 바로 멈추기

if [ $# -lt 1 ]; then                  # $# = 인자 개수
  echo "사용법: backup.sh <폴더>" >&2   # 에러는 stderr 로
  exit 1
fi
dir=$1
if [ ! -d "$dir" ]; then
  echo "폴더 없음: $dir" >&2
  exit 2
fi
mkdir -p ~/backups
out=~/backups/$(basename "$dir")-$(date +%Y%m%d).tar.gz
tar -czf "$out" -C "$(dirname "$dir")" "$(basename "$dir")"
echo "$out"
```

## 종료 코드가 중요한 이유
다른 프로그램(cron, CI, 다른 스크립트)은 **화면 글자가 아니라 종료 코드**로 성공·실패를 판단해요.
```bash
~/bin/backup.sh ~/projects/site && echo "성공했을 때만" || echo "실패했을 때만"
```
0 = 성공, 그 외 = 실패. 실패 종류마다 다른 숫자를 쓰면 원인을 구분할 수 있어요.

## 자주 쓰는 셸 문법
| 문법 | 뜻 |
|---|---|
| `$1`, `$2`, `$@`, `$#` | 인자, 모든 인자, 인자 개수 |
| `[ -f 파일 ]`, `[ -d 폴더 ]`, `[ -z "$v" ]` | 파일 있음, 폴더 있음, 비어 있음 |
| `$(명령)` | 명령 결과를 값으로 |
| `"$변수"` | **항상 따옴표!** (공백 든 경로 대비) |
| `>&2` | 에러 메시지는 표준 에러로 |

## 다음 단계
이 스크립트를 cron 에 등록하면 매일 자동 백업이 돼요 (`linux/14` 시나리오 참고).
