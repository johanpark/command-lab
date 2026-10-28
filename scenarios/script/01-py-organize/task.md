# 파일 정리 파이썬 스크립트 고치기

팀 공용 `~/inbox` 폴더가 엉망이에요. 동료가 종류별로 정리해 주는 파이썬 스크립트 `~/tools/organize.py` 를 만들어 뒀는데, 써 본 사람들이 이런 불만을 남겼어요.

> - 하위 폴더(`phone/`, `camera/`)에 있는 파일은 **그대로 남아요.**
> - `IMG_2041.JPG` 처럼 **대문자 확장자** 사진이 `others` 로 가요.
> - 폰과 카메라에 **같은 이름**의 사진이 있었는데, 정리하고 나니 **하나가 사라졌어요!** 😱

## 목표
1. `~/tools/organize.py` 의 버그 3개를 고치세요.
   - 하위 폴더 안의 파일까지 정리
   - 확장자는 대소문자 구분 없이 (`.JPG` = `.jpg`)
   - 같은 이름이 이미 있으면 덮어쓰지 말고 `이름_1.jpg`, `이름_2.jpg` … 처럼 새 이름으로
2. 고친 스크립트로 `~/inbox` 를 `~/sorted` 로 정리하세요. `~/inbox` 에는 **파일이 하나도 남지 않아야** 하고, **사라진 파일도 없어야** 해요.

> 채점할 때 고친 스크립트를 **새 테스트 폴더에도 한 번 더 돌려 봐요.** 손으로 옮기면 통과 못 해요!

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `cat ~/tools/organize.py` | 스크립트 읽기 |
| `nano ~/tools/organize.py` | 고치기 (`Ctrl+O` 저장, `Ctrl+X` 종료) |
| `python3 ~/tools/organize.py ~/inbox ~/sorted --dry-run` | 실제로 옮기지 않고 **계획만** 출력 |
| `python3 ~/tools/organize.py ~/inbox ~/sorted` | 실행 |
| `find ~/inbox -type f` / `tree ~/sorted` | 결과 확인 |

## 파이썬 한 줄 사전
| 코드 | 뜻 |
|---|---|
| `Path("a").iterdir()` | 폴더 바로 아래 항목만 |
| `Path("a").rglob("*")` | 하위 폴더까지 전부 |
| `p.suffix` / `p.suffix.lower()` | 확장자 `.JPG` / 소문자로 `.jpg` |
| `p.stem` | 확장자 뺀 이름 `IMG_2041` |
| `p.exists()` | 이미 있는지 |
