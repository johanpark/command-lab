cd ~/tools
python3 -m venv .venv
.venv/bin/pip install -q --no-index --find-links ~/wheels -r requirements.txt
.venv/bin/python report.py
