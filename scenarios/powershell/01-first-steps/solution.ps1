# 모범 풀이 (lab test 에서 학습자 권한으로 실행됨)
$file = Get-ChildItem ~/reports -Recurse -Filter summary.txt | Where-Object { $_.Directory.Name -eq 'Q3' -and $_.Directory.Parent.Name -eq '2026' }
$total = (Get-Content $file.FullName | Select-String '총매출: (\d+)').Matches[0].Groups[1].Value
Set-Content ~/answer.txt $total
New-Item -ItemType Directory ~/archive | Out-Null
Copy-Item $file.FullName ~/archive/
