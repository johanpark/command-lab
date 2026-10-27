#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
R="$H/recipes"
mkdir -p "$R"; give "$R"
spice=$(rand_pick 고추장 된장 간장 참기름)
as_learner bash -s <<SCRIPT
set -e
cd "$R"
git init -q
printf '# 김치찌개\n\n- 김치 300g\n- 돼지고기 200g\n- 두부 반 모\n' > kimchi.md
printf '# 불고기\n\n- 소고기 500g\n- 간장 5큰술\n- 배 반 개\n' > bulgogi.md
printf '# 비빔밥\n\n- 밥 한 공기\n- 나물 3종\n- 계란 1개\n' > bibimbap.md
printf '# 레시피 모음\n' > README.md
git add . && git commit -qm "레시피 세 개 추가" --date="2026-10-10T12:00:00"
printf -- '- 비법: $spice 1큰술\n' >> bibimbap.md
git commit -qam "비빔밥 비법 추가" --date="2026-10-15T12:00:00"
printf '# 된장찌개\n\n- 된장 2큰술\n' > doenjang.md
git add doenjang.md && git commit -qm "된장찌개 추가" --date="2026-10-18T12:00:00"
git rm -q bibimbap.md && git commit -qm "안 쓰는 레시피 정리" --date="2026-10-20T12:00:00"
printf -- '- 대파 1대\n' >> kimchi.md
git commit -qam "김치찌개에 대파 추가" --date="2026-10-22T12:00:00"
# 오늘의 사고들 (커밋 안 됨)
printf '아아아 망했다\n' > kimchi.md
rm bulgogi.md
SCRIPT
git -C "$R" rev-parse HEAD > /opt/cmdlab/secret/head
git -C "$R" show HEAD:kimchi.md > /opt/cmdlab/secret/kimchi
git -C "$R" show HEAD:bulgogi.md > /opt/cmdlab/secret/bulgogi
del=$(git -C "$R" log --format=%H --diff-filter=D -n 1 -- bibimbap.md)
git -C "$R" show "$del^:bibimbap.md" > /opt/cmdlab/secret/bibimbap
