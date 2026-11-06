# 설명: 같은 이름 처리를 빼먹으면 다른 폴더의 같은 이름 파일이 서로 덮어써 사라진다
# 실패해야: 사라진 파일이 없다
f=~/tools/organize.py
sed -i 's/if path.suffix in exts:/if path.suffix.lower() in exts:/' "$f"
sed -i 's/for f in sorted(src.iterdir()):/for f in sorted(src.rglob("*")):/' "$f"
python3 "$f" ~/inbox ~/sorted
