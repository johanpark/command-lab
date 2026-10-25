# 해설

```powershell
Get-ChildItem ~/reports -Recurse -File          # 전체 파일 둘러보기
Get-Content ~/reports/2026/Q3/summary.txt
Set-Content ~/answer.txt 54321
New-Item -ItemType Directory ~/archive
Copy-Item ~/reports/2026/Q3/summary.txt ~/archive/
```

## bash 와 비교
| 하고 싶은 일 | bash | PowerShell |
|---|---|---|
| 목록 | `ls -la` | `Get-ChildItem -Force` |
| 하위까지 찾기 | `find . -name '*.txt'` | `Get-ChildItem -Recurse -Filter *.txt` |
| 파일 쓰기 | `echo 1 > a.txt` | `Set-Content a.txt 1` (또는 `1 > a.txt`) |
| 폴더 만들기 | `mkdir -p a/b` | `New-Item -ItemType Directory a/b` |

## 기억할 것
- cmdlet 이름은 **동사-명사** 규칙이라 추측이 쉬워요: `Get-`, `Set-`, `New-`, `Remove-`, `Copy-`, `Move-` ...
- `ls`, `cd`, `cat` 같은 익숙한 이름은 **별칭(alias)** 이에요. `Get-Alias ls` 로 진짜 이름을 확인할 수 있어요.
- 명령어를 모를 땐 `Get-Command *Item*` 처럼 검색하세요.
