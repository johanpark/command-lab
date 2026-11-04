# 설명: -a 없이 -r 만 쓰면 권한·수정 시각이 원본과 달라진다
# 실패해야: 권한과 수정 시각
rsync -r --delete ~/photos/ /mnt/backup/photos/
