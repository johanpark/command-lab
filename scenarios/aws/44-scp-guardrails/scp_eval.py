"""SCP 묶음을 실제 AWS 규칙대로 평가한다.
입력(JSON): {"levels": [[정책 문서...], ...]}  (루트, OU, 계정 순 — 단계마다 Allow 가 하나는 있어야 한다)
            {"cases": [[id, action, region, instanceType|null], ...]}
출력: 한 줄에 "id<TAB>allow|deny" """
import fnmatch, json, sys

req = json.load(sys.stdin)


def lst(v):
    return v if isinstance(v, list) else [v]


def wild(pat, s):
    return fnmatch.fnmatchcase(s.lower(), pat.lower())


def cond_ok(cond, ctx):
    for op, kv in (cond or {}).items():
        ifexists = op.endswith('IfExists'); base = op[:-8] if ifexists else op
        for key, vals in kv.items():
            v = ctx.get(key.lower())
            if v is None:
                if ifexists or base.startswith('StringNot'):
                    continue
                return False
            vals = [str(x) for x in lst(vals)]
            ic = base.endswith('IgnoreCase')
            b = base.replace('IgnoreCase', '')
            if b in ('StringEquals', 'StringNotEquals'):
                hit = any((v.lower() == x.lower()) if ic else v == x for x in vals)
            elif b in ('StringLike', 'StringNotLike'):
                hit = any(fnmatch.fnmatchcase(v, x) for x in vals)
            else:
                raise SystemExit(f'ERR\t모르는 조건 연산자: {op}')
            if b.startswith('StringNot'):
                hit = not hit
            if not hit:
                return False
    return True


def matches(st, action, ctx):
    if 'Action' in st:
        ok = any(wild(a, action) for a in lst(st['Action']))
    elif 'NotAction' in st:
        ok = not any(wild(a, action) for a in lst(st['NotAction']))
    else:
        ok = False
    return ok and cond_ok(st.get('Condition'), ctx)


def decide(levels, action, region, itype):
    ctx = {'aws:requestedregion': region}
    if itype:
        ctx['ec2:instancetype'] = itype
    for docs in levels:
        ss = [s for d in docs for s in lst(d.get('Statement', []))]
        if any(s.get('Effect') == 'Deny' and matches(s, action, ctx) for s in ss):
            return 'deny'
        if not any(s.get('Effect') == 'Allow' and matches(s, action, ctx) for s in ss):
            return 'deny'
    return 'allow'


for cid, action, region, itype in req['cases']:
    print(f"{cid}\t{decide(req['levels'][cid.split(':')[0]], action, region, itype)}")
