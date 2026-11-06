# 설명: git push 만으로는 태그가 원격에 올라가지 않는다
# 실패해야: 원격(origin)에 v1.2.0
cd ~/app
rel=$(git log --format=%h --grep='^버전 1.2.0$')
git tag -a v1.2.0 "$rel" -m "1.2.0 릴리스"
git push -q origin main
