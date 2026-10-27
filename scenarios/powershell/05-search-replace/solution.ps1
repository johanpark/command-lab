Select-String -Path ~/configs/*.ini -Pattern '^password=' |
  Select-Object -ExpandProperty Filename -Unique |
  Set-Content ~/leaks.txt
Get-ChildItem ~/configs/*.ini | ForEach-Object {
  (Get-Content $_.FullName) -replace 'http://', 'https://' | Set-Content $_.FullName
}
