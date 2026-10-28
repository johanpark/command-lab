Import-Csv ~/onboarding/new-hires.csv | Where-Object Status -ne 'cancelled' | ForEach-Object {
  $acc = $_.Account.Trim().ToLower()
  $dir = "$HOME/homes/$acc"
  New-Item -ItemType Directory -Force -Path "$dir/Documents", "$dir/Desktop" | Out-Null
  Set-Content "$dir/welcome.txt" "환영합니다, $($_.Name)님! ($($_.Department))"
  $acc
} | Set-Content ~/created.txt
