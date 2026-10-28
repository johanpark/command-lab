# 해설

고친 핵심 부분:
```python
def category_of(path):
    for name, exts in CATEGORIES.items():
        if path.suffix.lower() in exts:          # 1. 대소문자 무시
            return name
    return "others"

def unique_path(target):
    n = 1
    candidate = target
    while candidate.exists():                     # 3. 같은 이름이면 번호 붙이기
        candidate = target.with_name(f"{target.stem}_{n}{target.suffix}")
        n += 1
    return candidate

for f in sorted(src.rglob("*")):                  # 2. 하위 폴더까지
    ...
    target = unique_path(dst / category_of(f) / f.name)
```

## 파일을 옮기는 스크립트의 3원칙
1. **dry-run 먼저.** 옮기기·지우기 전에 "무엇을 할지" 출력만 하는 모드를 만들어 두세요.
2. **덮어쓰기 금지.** `shutil.move`, `mv`, `cp` 모두 기본으로 덮어써요. (`mv -n`, `cp -n` 은 덮어쓰지 않음)
3. **개수 확인.** 실행 전후 파일 수를 세어 보면 사라진 파일을 바로 알 수 있어요.

## 셸로 하면?
```bash
find ~/inbox -type f -iname '*.jpg' -exec mv --backup=numbered -t ~/sorted/images {} +
```
가능하지만 종류가 많아지고 규칙이 복잡해지면 파이썬이 읽기도 고치기도 쉬워요. 반대로 한두 줄짜리 일은 셸이 빨라요. 둘 다 쓸 줄 알면 최고!

## 더 해볼 것
- 사진 찍은 날짜(`f.stat().st_mtime`)로 `2026-10/` 폴더 나누기
- 결과를 `logging` 으로 파일에 남기기
- `argparse` 로 `--dry-run` 같은 옵션을 제대로 받기
