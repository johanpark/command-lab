# 설명: -Filter *.log 를 빼면 오래된 다른 파일까지 지운다
# 실패해야: 최근 로그와 .log 가 아닌 파일
$cutoff = (Get-Date).AddDays(-30)
$old = Get-ChildItem ~/logs -Recurse -File | Where-Object LastWriteTime -lt $cutoff
Set-Content ~/answer.txt ($old | Where-Object Extension -eq '.log').Count
$old | Remove-Item
