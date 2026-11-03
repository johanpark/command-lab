"""AWS cron 식(EventBridge 예약 규칙, AWS Backup 등)을 실제로 굴려 보는 공용 도구.

    cron(분 시 일 월 요일 연도)   일·요일 중 하나는 ?, 일에 L(마지막 날), 요일은 1=일요일 또는 SUN-SAT

채점 스크립트에서:  import cron
    times = cron.fires('cron(0 18 L * ? *)', tz='Etc/UTC', start=..., end=...)   → KST 시각 목록
    cron.describe(times)  → '1월 2일 03:00, 2월 2일 03:00'
"""
import re
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

KST = ZoneInfo('Asia/Seoul')
DOW = {'SUN': 1, 'MON': 2, 'TUE': 3, 'WED': 4, 'THU': 5, 'FRI': 6, 'SAT': 7}
MON = {m: i + 1 for i, m in enumerate('JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC'.split())}

__all__ = ['KST', 'parse', 'fires', 'describe']


def _field(spec, lo, hi, names=None):
    if spec in ('*', '?'):
        return set(range(lo, hi + 1))
    out = set()
    for part in spec.split(','):
        step = 1
        if '/' in part:
            part, step = part.split('/')
            step = int(step)
        conv = lambda x: int((names or {}).get(x.upper(), x))  # noqa: E731
        if part == '*':
            a, b = lo, hi
        elif '-' in part:
            a, b = (conv(x) for x in part.split('-'))
        else:
            a = conv(part)
            b = a if step == 1 else hi
        if not (lo <= a <= hi and lo <= b <= hi):
            raise ValueError(part)
        out |= set(range(a, b + 1, step))
    return out


def parse(expr):
    """'cron(...)' → 시각(그 시간대의 datetime)을 받아 맞으면 True 를 돌려주는 함수. 형식이 틀리면 ValueError"""
    m = re.fullmatch(r'cron\((.*)\)', (expr or '').strip())
    f = m.group(1).split() if m else []
    if len(f) != 6:
        raise ValueError(f'cron(분 시 일 월 요일 연도) 형식이 아니에요: {expr}')
    mi, ho, dom, mo, dow, yr = f
    if (dom == '?') == (dow == '?'):
        raise ValueError(f'일과 요일 중 정확히 하나는 ? 여야 해요: {expr}')
    MI, HO, MO = _field(mi, 0, 59), _field(ho, 0, 23), _field(mo, 1, 12, MON)
    DW = None if dow == '?' else _field(dow, 1, 7, DOW)
    YR = None if yr in ('*', '?') else _field(yr, 1970, 2199)
    DM = None if dom in ('?', 'L') else _field(dom, 1, 31)

    def ok(t):
        if t.minute not in MI or t.hour not in HO or t.month not in MO or (YR and t.year not in YR):
            return False
        if dom == 'L':
            return (t + timedelta(days=1)).day == 1
        if DM is not None:
            return t.day in DM
        return ((t.isoweekday() % 7) + 1) in DW
    return ok


def fires(expr, tz='Etc/UTC', start=None, end=None):
    """start~end(UTC) 사이에 실제로 실행되는 시각들을 한국 시간으로. 기본: 2026-12-20 ~ 2027-02-10 (연말·월말·2월 포함)"""
    ok = parse(expr)
    zone = ZoneInfo(tz or 'Etc/UTC')
    t = start or datetime(2026, 12, 20, tzinfo=timezone.utc)
    end = end or datetime(2027, 2, 10, tzinfo=timezone.utc)
    out = []
    while t < end:
        if ok(t.astimezone(zone)):
            out.append(t.astimezone(KST))
        t += timedelta(minutes=1)
    return out


def describe(times, n=3):
    s = ', '.join(x.strftime('%-m월 %-d일 %H:%M') for x in times[:n])
    return s + (' ...' if len(times) > n else '') if times else '안 돌아요'
