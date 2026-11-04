# 설명: 2025년 Q3 요약을 보면 총매출이 다르다 (2026년 Q3 이어야 함)
# 실패해야: 2026년 Q3 총매출
$total = (Get-Content ~/reports/2025/Q3/summary.txt | Select-String '총매출: (\d+)').Matches[0].Groups[1].Value
Set-Content ~/answer.txt $total
New-Item -ItemType Directory ~/archive | Out-Null
Copy-Item ~/reports/2026/Q3/summary.txt ~/archive/
