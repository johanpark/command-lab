# 설명: 가장 큰 '폴더' 를 통째로 지우면 그 안의 다른 파일까지 사라진다
# 실패해야: 다른 파일은 그대로
d=$(du -s ~/app/* | sort -rn | head -n 1 | cut -f2)
echo "$d" > ~/answer.txt
rm -rf "$d"
