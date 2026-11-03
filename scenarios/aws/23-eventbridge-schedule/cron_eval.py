"""EventBridge 예약 규칙(cron, UTC)을 실제로 굴려 보고 한국 시간으로 판정한다 (공용 cron.py 사용).
사용: cron_eval.py cleanup 식 | cron_eval.py report 식 분   출력: ok|no<TAB>설명"""
import sys

import cron

kind, expr = sys.argv[1], sys.argv[2]
try:
    times = cron.fires(expr)
except ValueError as e:
    print(f'no\t{e}'); sys.exit()
days = {t.date() for t in times}
hm = sorted({t.strftime('%H:%M') for t in times})
if kind == 'cleanup':
    if hm == ['04:00'] and len(times) == len(days) and len(days) >= 50:
        print('ok\t')
    elif len(hm) == 1 and len(times) == len(days) and len(days) >= 50:
        h, m = map(int, hm[0].split(':'))
        hint = ' — 한국 시간을 그대로 넣었어요, UTC 로 바꾸세요' if hm[0] == '13:00' else ''
        print(f'no\t지금은 UTC {(h - 9) % 24}시 = 한국 {h}시{hint}')
    else:
        print(f'no\t매일 한 번이 아니에요 (한국 시간: {cron.describe(times)})')
else:
    m = int(sys.argv[3])
    wd = {t.isoweekday() for t in times}
    if hm != [f'03:{m:02d}']:
        print(f'no\t시각이 한국 시간 03:{m:02d} 이 아니에요 (지금: {", ".join(hm) or "안 돌아요"}) — UTC 로는 전날 18:{m:02d}')
    elif wd == {2, 3, 4, 5, 6}:
        print('no\t요일이 하루 밀렸어요: 한국 월요일 03시는 UTC 로 일요일 18시라 SUN-THU')
    elif wd != {1, 2, 3, 4, 5}:
        print(f'no\t요일이 한국 시간 월~금과 맞지 않아요 (지금: {cron.describe(times)})')
    else:
        print('ok\t')
