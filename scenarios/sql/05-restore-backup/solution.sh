cd ~
sqlite3 shop.db "
ATTACH DATABASE 'backup/shop-nightly.db' AS bak;
BEGIN;
INSERT INTO customers SELECT * FROM bak.customers WHERE city = '부산' AND id NOT IN (SELECT id FROM main.customers);
INSERT INTO customers VALUES (21, '노하은', '부산', 'user21@gmail.com', '2026-10-27');
COMMIT;
DETACH DATABASE bak;"
