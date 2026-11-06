# 설명: 계정 이름의 공백·대문자를 정리하지 않으면 폴더 이름이 제각각이 된다
# 실패해야: 소문자, 공백 없음
Import-Csv ~/onboarding/new-hires.csv | Where-Object Status -ne 'cancelled' | ForEach-Object {
  $dir = "$HOME/homes/$($_.Account)"
  New-Item -ItemType Directory -Force -Path "$dir/Documents", "$dir/Desktop" | Out-Null
  Set-Content "$dir/welcome.txt" "환영합니다, $($_.Name)님! ($($_.Department))"
  $_.Account
} | Set-Content ~/created.txt
