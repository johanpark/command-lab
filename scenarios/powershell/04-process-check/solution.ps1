$mem = Get-Process | Sort-Object WS -Descending | Select-Object -First 1
Set-Content ~/mem.txt $mem.Name
$cpu = Get-Process | Sort-Object CPU -Descending | Select-Object -First 1
Set-Content ~/cpu.txt $cpu.Name
Stop-Process -Id $cpu.Id
Start-Sleep -Milliseconds 300
