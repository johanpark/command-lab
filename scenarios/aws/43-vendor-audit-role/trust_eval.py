"""역할 신뢰 정책을 보고, 누가 어떤 조건으로 sts:AssumeRole 할 수 있는지 판정한다.
출력: 한 줄에 하나씩  OK|NO<TAB>설명"""
import fnmatch, json, sys

doc = json.loads(sys.argv[1]); vendor = sys.argv[2]; xid = sys.argv[3]; me = '123456789012'
stmts = doc.get('Statement', [])
stmts = [stmts] if isinstance(stmts, dict) else stmts


def lst(v):
    return v if isinstance(v, list) else [v]


def acts(s):
    return any(fnmatch.fnmatchcase('sts:assumerole', a.lower()) for a in lst(s.get('Action', [])))


def principals(s):
    p = s.get('Principal')
    if p == '*':
        return ['*']
    if not isinstance(p, dict):
        return []
    return [x for k, v in p.items() for x in lst(v) if k in ('AWS', '*')] + (['*'] if '*' in p else [])


def account(p):
    if p == '*':
        return '*'
    if p.isdigit():
        return p
    parts = p.split(':')
    return parts[4] if len(parts) > 4 else p


def xid_ok(s):
    c = s.get('Condition', {})
    for op, kv in c.items():
        if op.endswith('IfExists'):   # ...IfExists 는 키가 없어도 통과 → 외부 ID 를 안 보내도 맡을 수 있다
            continue
        for k, v in kv.items():
            if k.lower() == 'sts:externalid' and op in ('StringEquals', 'StringLike') and lst(v) == [xid]:
                return True
    return False


allows = [s for s in stmts if s.get('Effect') == 'Allow' and acts(s)]
if not allows:
    print('NO\tsts:AssumeRole 을 허용하는 문장이 없어요'); sys.exit()
who = sorted({account(p) for s in allows for p in principals(s)})
if who != [vendor]:
    bad = ', '.join('모든 AWS 계정(*)' if w == '*' else ('우리 계정' if w == me else w) for w in who if w != vendor) or '없음'
    print(f'NO\t맡을 수 있는 주체가 업체 계정({vendor})만이 아니에요: {bad}')
else:
    print('OK\t업체 계정만 맡을 수 있다')
miss = [s for s in allows if not xid_ok(s)]
print('OK\t외부 ID 가 맞을 때만' if not miss else
      f'NO\t외부 ID 조건이 없거나 값이 달라요 (Condition: {json.dumps(miss[0].get("Condition", {}), ensure_ascii=False)})')
