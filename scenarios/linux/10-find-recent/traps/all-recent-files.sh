# 설명: -name '*.conf' 를 빼면 최근에 바뀐 다른 파일까지 목록에 들어간다
# 실패해야: 최근 1일 이내 수정된 .conf 목록
find ~/app-config -type f -mtime -1 > ~/changed.txt
find ~/app-config -type f -empty -delete
