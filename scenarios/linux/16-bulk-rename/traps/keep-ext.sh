# 설명: 확장자를 바꾸지 않고 앞만 붙이면 .JPG 가 그대로 남는다
# 실패해야: .JPG 파일이 남아 있지 않다
cd ~/photos
for f in *.JPG; do mv "$f" "2026-trip_$f"; done
