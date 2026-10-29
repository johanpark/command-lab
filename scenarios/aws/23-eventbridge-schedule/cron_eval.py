"""EventBridge cron(분 시 일 월 요일 연도) 을 풀어서 비교한다. 출력: ok|no<TAB>설명"""
import re, sys

DOW = {'SUN': 1, 'MON': 2, 'TUE': 3, 'WED': 4, 'THU': 5, 'FRI': 6, 'SAT': 7}


def expand(field, lo, hi, names=None):
    if field in ('*', '?'):
        return set(range(lo, hi + 1))
    out = set()
    for part in field.split(','):
        step = 1
        if '/' in part:
            part, step = part.split('/'); step = int(step)
        if part == '*':
            a, b = lo, hi
        elif '-' in part:
            a, b = part.split('-'); a, b = conv(a, names), conv(b, names)
        else:
            a = b = conv(part, names)
        out |= set(range(a, b + 1, step))
    return out


def conv(v, names):
    v = v.upper()
    if names and v in names:
        return names[v]
    return int(v)


def parse(expr):
    m = re.fullmatch(r'cron\((.*)\)', (expr or '').strip())
    if not m:
        return None
    f = m.group(1).split()
    if len(f) != 6:
        return None
    try:
        return {
            'min': expand(f[0], 0, 59), 'hour': expand(f[1], 0, 23), 'dom': f[2], 'month': f[3],
            'dow_raw': f[4], 'dow': expand(f[4], 1, 7, DOW), 'year': f[5],
        }
    except ValueError:
        return None


kind, expr = sys.argv[1], sys.argv[2]
c = parse(expr)
if c is None:
    print(f'no\tcron(분 시 일 월 요일 연도) 형식이 아니에요: {expr}'); sys.exit()
everyday = c['month'] == '*' and c['year'] == '*' and (
    (c['dom'] == '*' and c['dow_raw'] == '?') or (c['dom'] == '?' and c['dow'] == set(range(1, 8))))
if kind == 'cleanup':
    want_h = {19}
    if c['min'] != {0} or c['hour'] != want_h:
        h = ','.join(map(str, sorted(c['hour'])))
        kst = ','.join(str((x + 9) % 24) for x in sorted(c['hour']))
        hint = ' — 한국 시간을 그대로 넣었어요, UTC 로 바꾸세요' if c['hour'] == {4} else ''
        print(f'no\t지금은 UTC {h}시 = 한국 {kst}시{hint}')
    elif not everyday:
        print('no\t매일이 아니에요: 일은 *, 요일은 ? 로')
    else:
        print('ok\t')
else:
    m = int(sys.argv[3])
    if c['min'] != {m} or c['hour'] != {18}:
        print(f'no\t시각이 한국 시간 03:{m} 이 아니에요: UTC 로는 전날 18:{m}')
    elif c['dom'] != '?' or c['month'] != '*' or c['year'] != '*':
        print('no\t일은 ?, 월·연도는 * 여야 해요')
    elif c['dow'] == {2, 3, 4, 5, 6}:
        print('no\t요일이 하루 밀렸어요: 한국 월요일 03시는 UTC 로 일요일 18시라 SUN-THU')
    elif c['dow'] != {1, 2, 3, 4, 5}:
        print('no\t요일이 한국 시간 월~금과 맞지 않아요')
    else:
        print('ok\t')
