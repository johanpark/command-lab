cd ~/photos
for f in *.JPG; do mv "$f" "2026-trip_${f%.JPG}.jpg"; done
