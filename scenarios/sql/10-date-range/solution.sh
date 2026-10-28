cd ~
sqlite3 shop.db "SELECT COUNT(*) FROM payments WHERE paid_at >= '2026-10-01' AND paid_at < '2026-11-01';" > count.txt
sqlite3 shop.db "SELECT SUM(amount) FROM payments WHERE paid_at >= '2026-10-01' AND paid_at < '2026-11-01';" > total.txt
