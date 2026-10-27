`Get-Process | Sort-Object WS -Descending | Select-Object -First 5 Name, Id, CPU, WS` 로 메모리 순 상위 5개를 보세요. WS(WorkingSet)는 바이트 단위예요.
---
PowerShell 자신(`pwsh`)도 메모리를 꽤 써요. 목록에서 pwsh 말고 **진짜 1등**을 찾으세요. MB 로 보기: `@{n='MB'; e={[int]($_.WS / 1MB)}}`
---
CPU 는 `Sort-Object CPU -Descending` 으로. 몇 초 기다렸다가 다시 보면 계속 늘어나는 프로세스가 범인이에요. 이름은 `Set-Content ~/cpu.txt 이름`
---
`Stop-Process -Name 이름 -WhatIf` 로 확인한 뒤 `-WhatIf` 를 빼고 실행하세요.
