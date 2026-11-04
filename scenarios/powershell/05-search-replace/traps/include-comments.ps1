# 설명: password= 를 아무 데서나 찾으면 주석(# password=) 이 든 파일까지 들어간다
# 실패해야: 평문 비밀번호가 있는 파일 이름
Select-String -Path ~/configs/*.ini -Pattern 'password=' | Select-Object -ExpandProperty Filename -Unique | Set-Content ~/leaks.txt
Get-ChildItem ~/configs/*.ini | ForEach-Object { (Get-Content $_.FullName) -replace 'http://', 'https://' | Set-Content $_.FullName }
