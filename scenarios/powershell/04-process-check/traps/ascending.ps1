# 설명: -Descending 을 빼면 가장 적게 쓰는 프로세스를 고른다
# 실패해야: 메모리를 가장 많이 쓰는
$mem = Get-Process | Sort-Object WS | Select-Object -First 1
Set-Content ~/mem.txt $mem.Name
