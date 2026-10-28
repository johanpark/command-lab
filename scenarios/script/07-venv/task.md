# pip install 이 막혀요 (가상환경 venv)

동료가 만든 재고 보고서 스크립트 `~/tools/report.py` 를 돌려야 해요. 그런데...

```
$ python3 ~/tools/report.py
ModuleNotFoundError: No module named 'labtable'

$ pip install -r ~/tools/requirements.txt
error: externally-managed-environment
× This environment is externally managed
```

최신 Ubuntu 는 시스템 파이썬에 pip 로 패키지를 까는 걸 막아 둬요. (운영체제가 쓰는 파이썬 패키지가 깨질 수 있어서요)

이 서버는 **외부 인터넷이 막혀 있어서**, 필요한 패키지 파일은 사내 폴더 **`~/wheels`** 에 받아 뒀어요.

## 목표
1. **`~/tools/.venv`** 에 가상환경(venv)을 만드세요.
2. `~/tools/requirements.txt` 의 패키지를 **`~/wheels` 에서** 그 가상환경에 설치하세요.
3. 가상환경의 파이썬으로 `report.py` 를 실행해서 **`~/tools/report.txt`** 를 만드세요.
4. **시스템 파이썬에는 설치하지 마세요.** (`--break-system-packages`, `sudo pip` 금지!)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `python3 -m venv 폴더` | 가상환경 만들기 |
| `source 폴더/bin/activate` / `deactivate` | 가상환경 켜기 / 끄기 (프롬프트 앞에 `(.venv)`) |
| `폴더/bin/pip install ...` | 켜지 않고 그 가상환경의 pip 를 바로 쓰기 |
| `pip install --no-index --find-links 폴더 -r requirements.txt` | 인터넷 대신 폴더에서 설치 |
| `pip list` | 설치된 패키지 |
| `which python` | 지금 쓰는 파이썬이 어디 건지 |
