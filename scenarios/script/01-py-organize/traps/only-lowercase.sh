# 설명: 대소문자만 고치고 하위 폴더(rglob)를 안 고치면 안쪽 파일이 inbox 에 남는다
# 실패해야: ~/inbox 에 남은 파일이 없다
# 실패해야: 하위 폴더·대문자·같은 이름
f=~/tools/organize.py
sed -i 's/if path.suffix in exts:/if path.suffix.lower() in exts:/' "$f"
python3 "$f" ~/inbox ~/sorted
