먼저 명단을 보세요: `Import-Csv ~/onboarding/new-hires.csv | Format-Table`. 계정(`Account`) 열에 `'  JKim'` 처럼 **공백과 대문자**가 섞인 게 보이나요? 공백은 표에서 잘 안 보이니 `Import-Csv ... | ForEach-Object { "[$($_.Account)]" }` 로 대괄호로 감싸 보면 확실해요.
---
취소된 사람 빼기: `Import-Csv ~/onboarding/new-hires.csv | Where-Object Status -ne 'cancelled'`. PowerShell 의 `-ne`, `-eq` 는 기본으로 **대소문자를 구분하지 않아요.**
---
한 사람씩 처리:
```powershell
Import-Csv ~/onboarding/new-hires.csv | Where-Object Status -ne 'cancelled' | ForEach-Object {
  $acc = $_.Account.Trim().ToLower()
  $dir = "$HOME/homes/$acc"
  New-Item -ItemType Directory -Force -Path "$dir/Documents", "$dir/Desktop" | Out-Null
  Set-Content "$dir/welcome.txt" "환영합니다, $($_.Name)님! ($($_.Department))"
  $acc
} | Set-Content ~/created.txt
```
---
`"...$($_.Name)..."` 처럼 **`$( )`** 로 감싸야 속성값이 들어가요. `"$_.Name"` 이라고 쓰면 `$_` 전체 뒤에 `.Name` 글자가 붙어 버려요. 확인: `Get-ChildItem ~/homes`, `Get-Content ~/homes/*/welcome.txt`
