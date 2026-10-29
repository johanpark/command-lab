#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
rm -rf "$H/blog" "$H/remote"; mkdir -p "$H/remote"; give "$H/remote"
color=$(rand_pick "#2563eb" "#16a34a" "#dc2626" "#9333ea")
as_learner bash -s <<SCRIPT
set -e
cd ~/remote && git init -q --bare -b main blog.git
git clone -q ~/remote/blog.git ~/blog 2>/dev/null
cd ~/blog
c() { GIT_AUTHOR_DATE="\$1" GIT_COMMITTER_DATE="\$1" git commit -qm "\$2"; }
echo "<h1>블로그</h1>" > index.html; git add . && c "2026-10-01T10:00:00" "블로그 시작"
echo "<p>소개</p>" > about.html; git add . && c "2026-10-10T10:00:00" "소개 페이지"
git push -q origin main 2>/dev/null
printf '<form>\n  <input name="id">\n  <input name="pw" type="password">\n</form>\n' > login.html
git add login.html && c "2026-10-28T10:00:00" "로긴 페이지 추가"
printf 'form { color: $color; }\n' > login.css
SCRIPT
git -C "$H/blog" rev-parse origin/main > /opt/cmdlab/secret/base
md5sum < "$H/blog/login.css" | cut -d' ' -f1 > /opt/cmdlab/secret/css
md5sum < "$H/blog/login.html" | cut -d' ' -f1 > /opt/cmdlab/secret/html
