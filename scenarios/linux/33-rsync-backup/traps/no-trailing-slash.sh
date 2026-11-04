# 설명: 원본 끝에 / 를 빼면 백업 안에 photos 폴더가 하나 더 생긴다
# 실패해야: 중첩되지 않았다
rsync -a --delete ~/photos /mnt/backup/photos/
