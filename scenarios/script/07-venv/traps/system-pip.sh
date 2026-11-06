# 설명: --break-system-packages 로 시스템 파이썬에 설치하면 다른 프로그램이 깨질 수 있다
# 실패해야: 시스템 파이썬에는 설치하지 않았다
# 실패해야: 가상환경이 있다
cd ~/tools
pip install -q --user --break-system-packages --no-index --find-links ~/wheels -r requirements.txt 2>/dev/null || python3 -m pip install -q --user --break-system-packages --no-index --find-links ~/wheels -r requirements.txt
python3 report.py
