# 해설

```bash
cd ~/tools
python3 -m venv .venv
.venv/bin/pip install --no-index --find-links ~/wheels -r requirements.txt
.venv/bin/python report.py
```

## 왜 시스템 pip 를 막을까?
Ubuntu·Debian 은 `apt` 로 설치한 파이썬 패키지로 시스템 도구를 돌려요. 여기에 `pip` 로 다른 버전을 덮어쓰면 운영체제 도구가 깨질 수 있어서, PEP 668 에 따라 `externally-managed-environment` 로 막아요. `--break-system-packages` 는 이름 그대로 "깨져도 좋다" 는 뜻이라 서버에서는 쓰지 마세요.

## 가상환경 = 프로젝트 전용 파이썬
```
~/tools/.venv/
├── bin/python   → 시스템 python3 를 가리키지만
├── bin/pip      → 설치는 여기로만
└── lib/python3.12/site-packages/labtable ...
```
- 프로젝트마다 패키지 버전이 달라도 서로 안 부딪혀요.
- 망가지면 폴더를 지우고 다시 만들면 끝. (`.venv` 는 Git 에 올리지 말고 `.gitignore` 에!)

## activate 안 해도 돼요
`source .venv/bin/activate` 는 PATH 앞에 `.venv/bin` 을 붙여 줄 뿐이에요. 스크립트나 **cron** 에서는 `/home/learner/tools/.venv/bin/python report.py` 처럼 **경로로 바로** 부르는 게 확실해요. 스크립트 첫 줄을 `#!/home/learner/tools/.venv/bin/python` 으로 바꾸는 방법도 있어요.

## 인터넷이 막힌 서버라면
인터넷 되는 PC 에서 `pip download -r requirements.txt -d wheels/` 로 받아 옮기고, 서버에서 `--no-index --find-links wheels/` 로 설치해요. 사내 PyPI 미러(`--index-url`)를 쓰는 회사도 많아요.

## 요즘 도구
`pipx` (명령어 도구를 각각의 venv 에), `uv` (아주 빠른 pip·venv 대체), `poetry` (의존성 관리) 도 많이 써요. 원리는 모두 같은 가상환경이에요.
