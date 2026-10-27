# 첫 셸 스크립트 만들기

매번 손으로 치던 백업 명령을 스크립트로 만들어 봅시다.

## 목표
`~/bin/backup.sh` 를 만드세요. 사용법은 `backup.sh <폴더>` 입니다.

| 상황 | 화면 출력 | 종료 코드 |
|---|---|---|
| 인자 없이 실행 | `사용법: backup.sh <폴더>` | **1** |
| 없는 폴더를 주면 | `폴더 없음: <폴더>` | **2** |
| 정상 | 만든 백업 파일의 경로 | **0** |

- 백업 파일 위치: `~/backups/<폴더이름>-<오늘날짜>.tar.gz` (예: `~/backups/site-20261027.tar.gz`)
- `~/backups` 폴더가 없으면 스크립트가 만들어야 해요.
- **실행 권한**이 있어서 `~/bin/backup.sh ~/projects/site` 처럼 바로 실행돼야 합니다.

## 써볼 문법
```bash
#!/usr/bin/env bash
dir="$1"                       # 첫 번째 인자
if [ -z "$dir" ]; then         # 비어 있으면
  echo "메시지"
  exit 1                       # 종료 코드 1 로 끝내기
fi
[ -d "$dir" ]                  # 폴더가 있는가?
name=$(basename "$dir")        # /home/a/site → site
today=$(date +%Y%m%d)          # 20261027
```
실행해 보고 `echo $?` 를 치면 방금 명령의 **종료 코드**가 보여요.
