f=~/tools/organize.py
sed -i 's/if path.suffix in exts:/if path.suffix.lower() in exts:/' "$f"
sed -i 's/for f in sorted(src.iterdir()):/for f in sorted(src.rglob("*")):/' "$f"
python3 - "$f" <<'PY'
import sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
s = s.replace(
    '        target = dst / category_of(f) / f.name\n',
    '        target = dst / category_of(f) / f.name\n'
    '        n = 1\n'
    '        while target.exists():\n'
    '            target = target.with_name(f"{f.stem}_{n}{f.suffix}")\n'
    '            n += 1\n')
open(p, "w", encoding="utf-8").write(s)
PY
python3 "$f" ~/inbox ~/sorted
