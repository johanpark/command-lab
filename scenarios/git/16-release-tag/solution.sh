cd ~/app
rel=$(git log --format=%h --grep='^버전 1.2.0$')
git tag -a v1.2.0 "$rel" -m "1.2.0 릴리스"
git push -q origin v1.2.0
git ls-remote --tags origin
