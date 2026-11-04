# 설명: Copy-Item 대신 Move-Item 을 쓰면 원본 요약이 사라진다
# 실패해야: 원본 요약 파일은 그대로
$file = Get-ChildItem ~/reports -Recurse -Filter summary.txt | Where-Object { $_.Directory.Name -eq 'Q3' -and $_.Directory.Parent.Name -eq '2026' }
$total = (Get-Content $file.FullName | Select-String '총매출: (\d+)').Matches[0].Groups[1].Value
Set-Content ~/answer.txt $total
New-Item -ItemType Directory ~/archive | Out-Null
Move-Item $file.FullName ~/archive/
