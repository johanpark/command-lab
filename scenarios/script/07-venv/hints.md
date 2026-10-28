`cat ~/tools/requirements.txt` 와 `ls ~/wheels` 를 보세요. 필요한 패키지 파일(`.whl`)이 다 있어요.
---
가상환경 만들기: `python3 -m venv ~/tools/.venv`. 그 안에 자기만의 `python`, `pip` 가 생겨요: `ls ~/tools/.venv/bin`
---
인터넷이 없으니 PyPI 대신 폴더를 보게: `~/tools/.venv/bin/pip install --no-index --find-links ~/wheels -r ~/tools/requirements.txt`. (`source ~/tools/.venv/bin/activate` 로 켜고 그냥 `pip install ...` 해도 돼요)
---
실행도 가상환경 파이썬으로: `~/tools/.venv/bin/python ~/tools/report.py`. 그냥 `python3 report.py` 는 시스템 파이썬이라 여전히 `ModuleNotFoundError` 예요. 확인: `cat ~/tools/report.txt`
