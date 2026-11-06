# 설명: 정리하는 김에 .zip 까지 지우면 안 된다
# 실패해야: .zip 파일은 ~/Downloads 에 그대로
cd ~/Downloads && mkdir -p images docs
mv *.jpg *.JPG *.png images/
mv *.pdf docs/
rm *.tmp *.zip
