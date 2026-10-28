먼저 `--dry-run` 으로 돌려서 출력을 보세요. 어떤 파일이 빠지고, 어떤 파일이 엉뚱한 폴더로 가는지 보여요. 스크립트는 몇 번이든 dry-run 으로 시험해도 안전해요.
---
하위 폴더: `src.iterdir()` 는 바로 아래만 봐요. `src.rglob("*")` 로 바꾸면 하위 폴더까지 다 나와요. (폴더는 `if not f.is_file(): continue` 가 걸러 줘요)
대소문자: `if path.suffix in exts:` → `if path.suffix.lower() in exts:`
---
덮어쓰기: `shutil.move` 는 같은 이름이 있으면 **말없이 덮어써요.** 옮기기 전에 이름이 비어 있을 때까지 번호를 붙이세요:
```python
target = dst / category_of(f) / f.name
n = 1
while target.exists():
    target = target.with_name(f"{f.stem}_{n}{f.suffix}")
    n += 1
```
---
주의: dry-run 에서는 파일을 실제로 안 옮기니 같은 이름 검사가 안 걸릴 수 있어요. 고친 뒤 `python3 ~/tools/organize.py ~/inbox ~/sorted` 로 실행하고, `find ~/inbox -type f | wc -l` (0이어야 함), `find ~/sorted -type f | wc -l` 로 확인!
