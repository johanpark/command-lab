"""AWS Backup 규칙의 cron 을 시간대까지 고려해 실제로 굴려 보고, 한국 시간으로 언제 도는지 판정한다 (공용 cron.py).
사용: backup_eval.py daily|monthly '규칙 JSON'   출력: ok|no<TAB>설명"""
import json, sys
from datetime import datetime, timedelta, timezone

import cron
from cron import KST

kind, rule = sys.argv[1], json.loads(sys.argv[2])
start = datetime(2026, 12, 20, tzinfo=timezone.utc)
try:
    fires = cron.fires(rule.get('ScheduleExpression'), rule.get('ScheduleExpressionTimezone') or 'Etc/UTC', start)
except (ValueError, AttributeError) as e:
    print(f"no\t{e if isinstance(e, ValueError) else '규칙에 ScheduleExpression 이 없어요'}"); sys.exit()
show = cron.describe
if kind == 'daily':
    days = {(start + timedelta(days=i)).astimezone(KST).date() for i in range(1, 50)}
    want = sorted(datetime(d.year, d.month, d.day, 3, tzinfo=KST) for d in days)
    got = [f for f in fires if f.date() in days]
    if got == want:
        print('ok\t')
    else:
        times = sorted({f.strftime('%H:%M') for f in got})
        per = len(got) / max(len(days), 1)
        if len(times) == 1 and abs(per - 1) < 0.05:
            print(f"no\t지금은 한국 시간 매일 {times[0]} 에 돌아요{' — UTC 로 바꾸지 않았어요 (한국 03시 = UTC 전날 18시)' if times[0] == '12:00' else ''}")
        else:
            print(f'no\t매일 한 번이 아니에요 (한국 시간: {show(got)})')
else:
    want = [datetime(2027, 1, 1, 3, tzinfo=KST), datetime(2027, 2, 1, 3, tzinfo=KST)]
    if fires == want:
        print('ok\t')
    elif [f.strftime('%H:%M') for f in fires] == ['03:00'] * len(fires) and fires and all(f.day == 2 for f in fires):
        print(f'no\t한국 시간으로 매달 2일에 돌아요 ({show(fires)}) — UTC 1일 18시는 한국 2일 03시예요. 한국 1일 03시는 UTC 로 "전달 말일" 18시')
    else:
        print(f'no\t한국 시간 매달 1일 03:00 이 아니에요 (지금: {show(fires) or "안 돌아요"})')
