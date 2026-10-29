#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
V="$H/tools/.venv"
if [ -x "$V/bin/python" ] && [ -f "$V/pyvenv.cfg" ]; then pass "~/tools/.venv 에 가상환경이 있다"
else fail "~/tools/.venv 에 가상환경이 있다 (python3 -m venv ~/tools/.venv)"; fi
ver=$(as_learner "$V/bin/python" -c 'import importlib.metadata as m; print(m.version("labtable"))' 2>/dev/null)
[ "$ver" = 1.4.0 ] && pass "가상환경에 labtable 1.4.0 이 설치됐다 (의존 패키지 포함)" || fail "가상환경에 labtable 1.4.0 이 설치됐다 (지금: ${ver:-없음})"
expect "가상환경에서 labtable 이 실제로 동작한다 (labcolor 도 설치됨)" as_learner "$V/bin/python" -c 'import labtable; labtable.render([("a", 1)])'
leak=""
for py in "runuser -u $LEARNER -- python3" "python3"; do $py -c 'import labtable' >/dev/null 2>&1 && leak=1; done
[ -z "$leak" ] && pass "시스템 파이썬에는 설치하지 않았다" || fail "시스템 파이썬에는 설치하지 않았다 (--break-system-packages 나 sudo pip 를 썼나요? pip uninstall 로 지워 주세요)"
if [ -f "$H/tools/report.txt" ] && cmp -s "$H/tools/report.txt" /opt/cmdlab/secret/report.txt; then pass "~/tools/report.txt 가 만들어졌다"
else fail "~/tools/report.txt 가 만들어졌다 ($( [ -f "$H/tools/report.txt" ] && echo '내용이 달라요' || echo '아직 없어요 — 가상환경의 python 으로 report.py 를 실행'))"; fi
finish
