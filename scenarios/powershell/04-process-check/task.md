# 프로세스 살펴보고 정리하기

Windows 의 작업 관리자를 PowerShell 로 해 봅시다. 서버가 느려졌다는 연락을 받았어요.

## 목표
1. **메모리(WorkingSet)를 가장 많이 쓰는** 프로세스 이름 → `~/mem.txt`
2. **CPU 시간을 가장 많이 쓴** 프로세스 이름 → `~/cpu.txt`
3. CPU 를 쓰는 그 프로세스는 **멈춰서 CPU 만 먹고 있는 작업**이래요. 그것만 **종료**하세요.
   (메모리를 쓰는 프로세스는 캐시라서 그대로 둬야 해요)

## 써볼 cmdlet
| cmdlet | 하는 일 |
|---|---|
| `Get-Process` | 프로세스 목록 (별칭 `ps`, `gps`) |
| `Get-Process \| Sort-Object WS -Descending \| Select-Object -First 5` | 메모리 순 상위 5개 |
| `Sort-Object CPU -Descending` | 누적 CPU 시간(초) 순 |
| `Select-Object Name, Id, CPU, @{n='MB';e={[int]($_.WS / 1MB)}}` | 원하는 열만, 계산한 열 추가 |
| `Stop-Process -Name 이름 -WhatIf` | 무엇을 종료할지 미리보기 |
| `Stop-Process -Id 번호` | 종료 |
