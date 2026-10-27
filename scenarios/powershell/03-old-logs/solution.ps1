$cutoff = (Get-Date).AddDays(-30)
$old = Get-ChildItem ~/logs -Recurse -File -Filter *.log | Where-Object LastWriteTime -lt $cutoff
Set-Content ~/answer.txt $old.Count
$old | Remove-Item
