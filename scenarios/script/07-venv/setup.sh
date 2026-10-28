#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
T="$H/tools"; W="$H/wheels"; rm -rf "$T" "$W"; mkdir -p "$T" "$W"
# 사내 패키지 두 개를 wheel 파일로 만든다 (labtable 은 labcolor 에 의존)
python3 - "$W" <<'PY'
import base64, hashlib, sys, zipfile
out = sys.argv[1]
def wheel(name, version, files, requires=()):
    dist = f"{name}-{version}.dist-info"
    meta = f"Metadata-Version: 2.1\nName: {name}\nVersion: {version}\nSummary: 사내 {name} 패키지\n"
    meta += "".join(f"Requires-Dist: {r}\n" for r in requires)
    files = dict(files)
    files[f"{dist}/METADATA"] = meta
    files[f"{dist}/WHEEL"] = "Wheel-Version: 1.0\nGenerator: cmdlab\nRoot-Is-Purelib: true\nTag: py3-none-any\n"
    record = []
    for path, text in files.items():
        data = text.encode()
        digest = base64.urlsafe_b64encode(hashlib.sha256(data).digest()).rstrip(b"=").decode()
        record.append(f"{path},sha256={digest},{len(data)}")
    record.append(f"{dist}/RECORD,,")
    files[f"{dist}/RECORD"] = "\n".join(record) + "\n"
    with zipfile.ZipFile(f"{out}/{name}-{version}-py3-none-any.whl", "w") as z:
        for path, text in files.items():
            z.writestr(path, text)
wheel("labcolor", "2.1.0", {"labcolor/__init__.py": "def mark(n):\n    return '⚠' if n < 10 else ' '\n"})
wheel("labtable", "1.4.0", {"labtable/__init__.py": '''from labcolor import mark


def render(rows):
    width = max(len(name) for name, _ in rows)
    lines = [f"{'상품'.ljust(width)}  재고", "-" * (width + 8)]
    for name, qty in rows:
        lines.append(f"{name.ljust(width)}  {qty:>4} {mark(qty)}")
    return "\\n".join(lines) + "\\n"
'''}, requires=["labcolor>=2.0"])
# 헷갈리라고 옛 버전도 하나
wheel("labtable", "0.9.0", {"labtable/__init__.py": "def render(rows):\n    raise RuntimeError('labtable 0.9 는 더 이상 지원하지 않아요')\n"})
PY
printf 'labtable==1.4.0\n' > "$T/requirements.txt"
stock=$(for p in 키보드 마우스 모니터 웹캠 헤드셋; do printf '("%s", %d), ' "$p" "$(rand_int 0 40)"; done)
cat > "$T/report.py" <<PY
#!/usr/bin/env python3
"""재고 보고서를 표로 만들어 report.txt 에 저장한다."""
from pathlib import Path

import labtable

stock = [$stock]
text = labtable.render(stock)
print(text)
Path(__file__).with_name("report.txt").write_text(text, encoding="utf-8")
PY
give "$T" "$W"
# 정답: 패키지 소스로 직접 계산
D=$(mktemp -d); (cd "$D" && for w in "$W"/labcolor-2.1.0-*.whl "$W"/labtable-1.4.0-*.whl; do python3 -m zipfile -e "$w" .; done)
PYTHONPATH="$D" python3 -c "import labtable; open('/opt/cmdlab/secret/report.txt', 'w', encoding='utf-8').write(labtable.render([$stock]))"
rm -rf "$D"
