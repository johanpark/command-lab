# 설명: 깨진 링크를 먼저 다 지우면 고쳐야 할 uploads 링크까지 사라진다
# 실패해야: /srv/uploads 를 가리킨다
find ~/site -xtype l | wc -l > ~/answer.txt
find ~/site -xtype l -delete
