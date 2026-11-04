# 설명: 숨김 파일(. 으로 시작)을 빼고 세면 개수가 모자란다
# 실패해야: 깨진 링크 개수
find ~/site -xtype l ! -name '.*' | wc -l > ~/answer.txt
ln -sfn /srv/uploads ~/site/releases/v3/uploads
find ~/site -xtype l -delete
