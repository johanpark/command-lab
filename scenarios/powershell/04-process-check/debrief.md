# 해설

```powershell
Get-Process | Sort-Object WS -Descending |
  Select-Object -First 5 Name, Id, @{n='MB'; e={[int]($_.WS / 1MB)}}
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, Id, CPU

Set-Content ~/mem.txt cache-server
Set-Content ~/cpu.txt stuck-export
Stop-Process -Name stuck-export -WhatIf
Stop-Process -Name stuck-export
```

## 속성 정리
| 속성 | 뜻 |
|---|---|
| `WS` (WorkingSet) | 지금 실제로 쓰는 메모리 (작업 관리자의 "메모리") |
| `CPU` | 지금까지 쓴 **누적** CPU 시간(초). "지금" 사용률이 아니에요 |
| `Id` | 프로세스 번호 (PID) |
| `StartTime` | 시작 시각 |

## 함정 포인트
- `Get-Process` 결과의 기본 표에 보이는 `WS(M)` 같은 열 이름은 **표시용**이에요. 정렬할 땐 실제 속성 이름 `WS` 를 씁니다. `Get-Process | Get-Member` 로 진짜 속성 이름을 볼 수 있어요.
- CPU 는 누적값이라 오래 켜진 프로세스가 높게 나올 수 있어요. "지금" 바쁜 걸 보려면 몇 초 간격으로 두 번 재서 차이를 보세요.

## bash 와 비교
| 하고 싶은 일 | bash | PowerShell |
|---|---|---|
| 메모리 순 | `ps aux --sort=-rss \| head` | `Get-Process \| Sort-Object WS -Desc` |
| 이름으로 종료 | `pkill -x 이름` | `Stop-Process -Name 이름` |
| 미리보기 | (없음) | `-WhatIf` |
