"""AWS Backup 규칙의 cron 을 시간대까지 고려해 실제로 굴려 보고, 한국 시간으로 언제 도는지 판정한다.
사용: backup_eval.py daily|monthly '규칙 JSON'   출력: ok|no<TAB>설명"""
import json, re, sys
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

KST = ZoneInfo('Asia/Seoul')
DOW = {'SUN': 1, 'MON': 2, 'TUE': 3, 'WED': 4, 'THU': 5, 'FRI': 6, 'SAT': 7}
MON = {m: i + 1 for i, m in enumerate('JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC'.split())}


def field(spec, lo, hi, names=None):
    if spec in ('*', '?'):
        return set(range(lo, hi + 1))
    out = set()
    for part in spec.split(','):
        step = 1
        if '/' in part:
            part, step = part.split('/'); step = int(step)
        if part == '*':
            a, b = lo, hi
        elif '-' in part:
            a, b = (int((names or {}).get(x.upper(), x)) for x in part.split('-'))
        else:
            a = int((names or {}).get(part.upper(), part)); b = a if step == 1 else hi
        out |= set(range(a, b + 1, step))
    return out


def matcher(expr):
    m = re.fullmatch(r'cron\((.*)\)', (expr or '').strip())
    f = m.group(1).split() if m else []
    if len(f) != 6:
        raise ValueError(expr)
    mi, ho, dom, mo, dow, yr = f
    MI, HO, MO = field(mi, 0, 59), field(ho, 0, 23), field(mo, 1, 12, MON)
    DW = None if dow == '?' else field(dow, 1, 7, DOW)
    YR = None if yr in ('*', '?') else field(yr, 1970, 2199)

    def ok(t):
        if t.minute not in MI or t.hour not in HO or t.month not in MO or (YR and t.year not in YR):
            return False
        if dom == 'L':
            d_ok = (t + timedelta(days=1)).day == 1
        elif dom == '?':
            d_ok = True
        else:
            d_ok = t.day in field(dom, 1, 31)
        w_ok = True if DW is None else ((t.isoweekday() % 7) + 1) in DW
        return d_ok and w_ok
    return ok


kind, rule = sys.argv[1], json.loads(sys.argv[2])
try:
    ok = matcher(rule.get('ScheduleExpression'))
except (ValueError, AttributeError):
    print(f"no\tcron(분 시 일 월 요일 연도) 형식이 아니에요: {rule.get('ScheduleExpression')}"); sys.exit()
tz = ZoneInfo(rule.get('ScheduleExpressionTimezone') or 'Etc/UTC')
start = datetime(2026, 12, 20, tzinfo=timezone.utc); end = datetime(2027, 2, 10, tzinfo=timezone.utc)
fires, t = [], start
while t < end:
    if ok(t.astimezone(tz)):
        fires.append(t.astimezone(KST))
    t += timedelta(minutes=1)
show = lambda xs: ', '.join(x.strftime('%-m월 %-d일 %H:%M') for x in xs[:3]) + (' ...' if len(xs) > 3 else '')
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
