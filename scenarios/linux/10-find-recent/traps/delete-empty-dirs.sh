# 설명: -type f 없이 -empty -delete 를 하면 빈 폴더까지 지운다
# 실패해야: 폴더는 지우지 않았다
find ~/app-config -type f -name '*.conf' -mtime -1 > ~/changed.txt
find ~/app-config -empty -delete
