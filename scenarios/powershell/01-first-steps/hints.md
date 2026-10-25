`Get-ChildItem ~/reports` 로 시작하세요. 폴더가 연도별로 나뉘어 있어요. `Set-Location` 으로 들어가면서 다시 `Get-ChildItem`.
---
한 번에 다 보기: `Get-ChildItem ~/reports -Recurse`. 파일 이름만 보고 싶으면 `-Recurse -File | Select-Object FullName`
---
Q3 폴더 안의 summary 파일을 `Get-Content` 로 읽어 보세요. `Get-Content ~/reports/2026/Q3/summary.txt`
---
`Set-Content ~/answer.txt 숫자` → `New-Item -ItemType Directory ~/archive` → `Copy-Item ~/reports/2026/Q3/summary.txt ~/archive/`
