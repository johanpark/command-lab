# 설명: -Recurse 를 빼면 하위 폴더의 오래된 로그가 남는다
# 실패해야: 30일보다 오래된 .log 개수
# 실패해야: 오래된 .log 파일을 모두
$cutoff = (Get-Date).AddDays(-30)
$old = Get-ChildItem ~/logs -File -Filter *.log | Where-Object LastWriteTime -lt $cutoff
Set-Content ~/answer.txt $old.Count
$old | Remove-Item
