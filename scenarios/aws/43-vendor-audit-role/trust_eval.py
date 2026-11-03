"""역할 신뢰 정책을 보고, 누가 어떤 조건으로 sts:AssumeRole 할 수 있는지 판정한다 (공용 policy.py 사용).
출력: 한 줄에 하나씩  OK|NO<TAB>설명"""
import json, sys

import policy

doc = json.loads(sys.argv[1]); vendor = sys.argv[2]; xid = sys.argv[3]; me = '123456789012'
grants = [(kind, v, s) for kind, v, s in policy.assume_principals(doc) if kind == 'AWS']
if not grants:
    print('NO\tsts:AssumeRole 을 허용하는 문장이 없어요'); sys.exit()
who = sorted({policy.account_of(v) for _, v, _ in grants})
if who != [vendor]:
    bad = ', '.join('모든 AWS 계정(*)' if w == '*' else ('우리 계정' if w == me else w) for w in who if w != vendor) or '없음'
    print(f'NO\t맡을 수 있는 주체가 업체 계정({vendor})만이 아니에요: {bad}')
else:
    print('OK\t업체 계정만 맡을 수 있다')
# 외부 ID: 보내지 않거나 틀리면 거부, 맞으면 허용돼야 한다 (StringEqualsIfExists 는 안 보내도 통과라 탈락)
stmts = [s for _, _, s in grants]
ok_with = all(policy.matches(s, 'sts:AssumeRole', ctx={'sts:ExternalId': xid}) for s in stmts)
open_without = [s for s in stmts if policy.matches(s, 'sts:AssumeRole', ctx={})
                or policy.matches(s, 'sts:AssumeRole', ctx={'sts:ExternalId': 'wrong-id'})]
if ok_with and not open_without:
    print('OK\t외부 ID 가 맞을 때만')
else:
    s = (open_without or stmts)[0]
    print(f'NO\t외부 ID 조건이 없거나 값이 달라요 (Condition: {json.dumps(s.get("Condition", {}), ensure_ascii=False)})')
