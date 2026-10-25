# PowerShell 첫걸음

PowerShell은 Windows의 기본 셸이지만, 맥과 리눅스에서도 똑같이 동작합니다. 명령어는 **`동사-명사`** 형태(cmdlet)로 생겼어요.

회계팀이 3분기 매출 요약 파일을 찾아 달라고 합니다.

## 목표
1. `~/reports` 아래 어딘가에 있는 **2026년 3분기(Q3) 요약 파일**을 찾아 **총매출** 숫자를 `~/answer.txt` 에 저장하세요.
   ```powershell
   Set-Content ~/answer.txt 12345
   ```
2. `~/archive` 폴더를 만들고 그 요약 파일을 **복사**해 넣으세요. (원본은 그대로)

## 써볼 명령어
| cmdlet | 별칭(alias) | 하는 일 |
|---|---|---|
| `Get-Location` | `pwd` | 현재 위치 |
| `Get-ChildItem` | `ls`, `dir`, `gci` | 목록 (`-Recurse` 하위 폴더까지) |
| `Set-Location` | `cd` | 이동 |
| `Get-Content` | `cat`, `gc` | 파일 읽기 |
| `New-Item -ItemType Directory` | `mkdir` | 폴더 만들기 |
| `Copy-Item` | `cp`, `copy` | 복사 |

> 💡 `Get-Help Get-ChildItem -Examples` 로 사용 예시를 볼 수 있어요. 탭(Tab) 자동 완성은 cmdlet 이름과 옵션에도 동작합니다.
