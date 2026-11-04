# 설명: 따옴표 없이 mv 하면 공백이 든 이름이 쪼개진다
# 실패해야: 2026-trip_이름.jpg
cd ~/photos
for f in *.JPG; do mv $f 2026-trip_${f%.JPG}.jpg; done
