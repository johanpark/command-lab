cd ~/recipes
git restore kimchi.md bulgogi.md
del=$(git log --format=%h --diff-filter=D -n 1 -- bibimbap.md)
git restore --source="$del^" bibimbap.md
git add bibimbap.md
git commit -qm "비빔밥 레시피 복구"
