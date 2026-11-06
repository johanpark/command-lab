# 설명: cat 으로 이어 붙이면 인코딩이 섞이고 머리글이 세 번 들어간다
# 실패해야: 올바른 UTF-8
mkdir -p ~/report
cat ~/exports/*.csv > ~/report/merged.csv
