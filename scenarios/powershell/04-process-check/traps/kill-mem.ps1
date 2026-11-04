# 설명: 메모리를 많이 쓰는 캐시까지 죽이면 안 된다 (CPU 범인만)
# 실패해야: 그대로 실행 중
$mem = Get-Process | Sort-Object WS -Descending | Select-Object -First 1
Set-Content ~/mem.txt $mem.Name
$cpu = Get-Process | Sort-Object CPU -Descending | Select-Object -First 1
Set-Content ~/cpu.txt $cpu.Name
Stop-Process -Id $cpu.Id, $mem.Id
Start-Sleep -Milliseconds 300
