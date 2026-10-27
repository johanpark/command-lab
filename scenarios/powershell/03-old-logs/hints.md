`Get-ChildItem ~/logs -Recurse -File | Select-Object FullName, LastWriteTime` 로 어떤 파일들이 언제 수정됐는지 보세요.
---
기준 날짜를 변수에: `$cutoff = (Get-Date).AddDays(-30)`. 그다음 `Get-ChildItem ~/logs -Recurse -File -Filter *.log | Where-Object LastWriteTime -lt $cutoff`
---
결과를 변수에 담아 두면 편해요: `$old = Get-ChildItem ...(위 명령)...`. 개수는 `$old.Count`, 저장은 `Set-Content ~/answer.txt $old.Count`
---
`$old | Remove-Item -WhatIf` 로 확인 후 `$old | Remove-Item`. `-Recurse` 를 빼면 `archive` 하위 폴더의 로그를 놓쳐요!
