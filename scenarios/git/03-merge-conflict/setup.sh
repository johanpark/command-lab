#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/website"
mkdir -p "$R"
give "$R"
as_learner bash -s <<'SCRIPT'
set -e
cd ~/website
git init -q
cat > index.html <<'HTML'
<!doctype html>
<html>
<body>
  <header>
    <h1>명령어 연습장</h1>
  </header>
  <main>
    <p>리눅스 명령어를 연습하는 곳입니다.</p>
  </main>
</body>
</html>
HTML
git add . && git commit -qm "첫 페이지"

git switch -qc feature/new-title
sed -i 's|<h1>명령어 연습장</h1>|<h1>커맨드 연습장</h1>|' index.html
sed -i 's|</body>|  <footer>© 2026 Command Lab</footer>\n</body>|' index.html
git commit -qam "사이트 이름 변경, footer 추가"

git switch -q main
sed -i 's|<h1>명령어 연습장</h1>|<h1>명령어 연습장 - 매일 조금씩</h1>|' index.html
sed -i 's|^<body>$|<body>\n  <nav>홈 · 시나리오 · 기록</nav>|' index.html
git commit -qam "부제와 nav 추가"
SCRIPT
git -C "$R" rev-parse feature/new-title > /opt/cmdlab/secret/feature
