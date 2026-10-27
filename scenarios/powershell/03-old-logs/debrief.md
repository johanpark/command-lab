# 해설

```powershell
$cutoff = (Get-Date).AddDays(-30)
$old = Get-ChildItem ~/logs -Recurse -File -Filter *.log |
       Where-Object LastWriteTime -lt $cutoff
$old | Select-Object FullName, LastWriteTime      # 대상 확인
Set-Content ~/answer.txt $old.Count
$old | Remove-Item -WhatIf                         # 미리보기
$old | Remove-Item
```

## 기억할 것
- **`-WhatIf`** 는 PowerShell 의 강력한 안전장치예요. `Remove-Item`, `Move-Item`, `Stop-Process` 등 변경하는 cmdlet 대부분이 지원합니다. `-Confirm` 은 하나씩 물어봐요.
- 날짜는 문자열이 아니라 **DateTime 객체**라서 `-lt`, `-gt` 로 그대로 비교할 수 있어요.
- `-Recurse` 가 없으면 `archive/2026` 같은 하위 폴더를 놓칩니다.
- 결과를 **변수에 담아 두면** 확인 → 개수 → 삭제를 같은 대상으로 정확히 할 수 있어요.

## bash 로 하면
```bash
find ~/logs -name '*.log' -mtime +30 | wc -l
find ~/logs -name '*.log' -mtime +30 -delete
```

## 실무 응용 (Windows)
```powershell
# 임시 폴더에서 7일 넘은 파일 정리
Get-ChildItem $env:TEMP -Recurse -File | Where-Object LastWriteTime -lt (Get-Date).AddDays(-7) | Remove-Item -WhatIf
# 큰 파일 상위 10개
Get-ChildItem C:\ -Recurse -File -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 10 FullName, Length
```
