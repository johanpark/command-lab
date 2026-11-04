# 설명: *.jpg 만 옮기면 대문자 확장자(.JPG) 사진이 남는다
# 실패해야: 사진(.jpg/.JPG/.png)이 모두
# 실패해야: 사진/문서가 남아 있지 않다
cd ~/Downloads && mkdir -p images docs
mv *.jpg *.png images/
mv *.pdf docs/
rm *.tmp
