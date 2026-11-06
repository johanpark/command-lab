# 설명: .ini 로 거르지 않고 폴더 전체를 바꾸면 README.txt 까지 바뀐다
# 실패해야: README.txt 는 건드리지 않았다
Select-String -Path ~/configs/*.ini -Pattern '^password=' | Select-Object -ExpandProperty Filename -Unique | Set-Content ~/leaks.txt
Get-ChildItem ~/configs -File | ForEach-Object { (Get-Content $_.FullName) -replace 'http', 'https' | Set-Content $_.FullName }
