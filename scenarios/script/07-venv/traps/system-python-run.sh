# 설명: 가상환경에 설치하고도 시스템 python3 으로 실행하면 모듈을 못 찾는다
# 실패해야: report.txt 가 만들어졌다
cd ~/tools
python3 -m venv .venv
.venv/bin/pip install -q --no-index --find-links ~/wheels -r requirements.txt
python3 report.py
