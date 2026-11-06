# 설명: INSERT OR REPLACE 로 백업 전체를 넣으면 오늘 고친 이메일이 옛 값으로 돌아간다
# 실패해야: 오늘 수정한 이메일
cd ~
sqlite3 shop.db "ATTACH DATABASE 'backup/shop-nightly.db' AS bak; INSERT OR REPLACE INTO customers SELECT * FROM bak.customers; DETACH DATABASE bak;"
