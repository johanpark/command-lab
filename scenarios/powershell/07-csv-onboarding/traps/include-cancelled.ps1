# 설명: 취소자를 거르지 않으면 입사하지 않는 사람의 폴더까지 생긴다
# 실패해야: 있으면 안 되는 폴더
Import-Csv ~/onboarding/new-hires.csv | ForEach-Object {
  $acc = $_.Account.Trim().ToLower()
  $dir = "$HOME/homes/$acc"
  New-Item -ItemType Directory -Force -Path "$dir/Documents", "$dir/Desktop" | Out-Null
  Set-Content "$dir/welcome.txt" "환영합니다, $($_.Name)님! ($($_.Department))"
  $acc
} | Set-Content ~/created.txt
