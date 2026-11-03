"""AWS 정책(IAM 정책, 신뢰 정책, SCP)을 실제 평가 규칙대로 계산하는 공용 도구.

채점 스크립트에서:  import policy  (helpers.sh 가 PYTHONPATH 를 잡아 준다)

    docs = [정책 문서(dict 또는 JSON 글자), ...]
    policy.decide(docs, 's3:GetObject', 'arn:aws:s3:::bucket/a.csv')        → 'allow' | 'deny' | 'implicit'
    policy.allowed(docs, 's3:GetObject', 'arn:aws:s3:::bucket/a.csv')       → True / False
    policy.scp_decide([[루트 SCP...], [OU SCP...], [계정 SCP...]], 'ec2:RunInstances', {'aws:RequestedRegion': 'us-east-1'})
    policy.assume_principals(trust_doc)  → sts:AssumeRole 을 허용하는 (주체, 문장) 목록
"""
import json
import re

__all__ = ['wild', 'statements', 'matches', 'decide', 'allowed', 'scp_decide', 'assume_principals', 'account_of']


def lst(v):
    if v is None:
        return []
    return v if isinstance(v, list) else [v]


def wild(pattern, value, ignore_case=False):
    """IAM 와일드카드: * 는 아무 글자 여러 개, ? 는 한 글자. (fnmatch 와 달리 [ ] 는 그냥 글자)"""
    rx = ''.join('.*' if c == '*' else '.' if c == '?' else re.escape(c) for c in str(pattern))
    return re.fullmatch(rx, str(value), re.IGNORECASE | re.DOTALL if ignore_case else re.DOTALL) is not None


def statements(doc):
    """정책 문서(dict, JSON 글자) → 문장 목록"""
    if isinstance(doc, str):
        doc = json.loads(doc)
    return [s for s in lst((doc or {}).get('Statement')) if isinstance(s, dict)]


def _cond_ok(cond, ctx):
    ctx = {k.lower(): v for k, v in (ctx or {}).items()}
    for op, kv in (cond or {}).items():
        if_exists = op.endswith('IfExists')
        base = op[:-len('IfExists')] if if_exists else op
        for key, want in (kv or {}).items():
            got = ctx.get(key.lower())
            if base == 'Null':   # "Null": {"키": "true"} → 키가 없어야 한다
                if (got is None) != (str(lst(want)[0]).lower() == 'true'):
                    return False
                continue
            if got is None:
                if if_exists or base.startswith(('StringNot', 'ArnNot')):
                    continue   # 키가 없으면 IfExists·부정 연산자는 통과
                return False
            gots = [str(g) for g in lst(got)]
            wants = [str(w) for w in lst(want)]
            neg = base.startswith(('StringNot', 'ArnNot', 'NumericNot'))
            b = base.replace('Not', '', 1) if neg else base
            ic = b.endswith('IgnoreCase')
            b = b.replace('IgnoreCase', '')
            if b in ('StringEquals',):
                hit = any((g.lower() == w.lower()) if ic else g == w for g in gots for w in wants)
            elif b in ('StringLike', 'ArnLike', 'ArnEquals'):
                hit = any(wild(w, g) for g in gots for w in wants)
            elif b == 'Bool':
                hit = any(g.lower() == w.lower() for g in gots for w in wants)
            elif b.startswith('Numeric'):
                cmp = {'NumericEquals': lambda a, c: a == c, 'NumericLessThan': lambda a, c: a < c,
                       'NumericLessThanEquals': lambda a, c: a <= c, 'NumericGreaterThan': lambda a, c: a > c,
                       'NumericGreaterThanEquals': lambda a, c: a >= c}.get(b)
                if cmp is None:
                    raise ValueError(f'모르는 조건 연산자: {op}')
                hit = any(cmp(float(g), float(w)) for g in gots for w in wants)
            else:
                raise ValueError(f'모르는 조건 연산자: {op}')
            if neg:
                hit = not hit
            if not hit:
                return False
    return True


def matches(stmt, action, resource='*', ctx=None):
    """문장이 이 요청(작업, 리소스, 조건 값)에 해당하는가 (Effect 는 보지 않는다)"""
    if 'Action' in stmt:
        ok = any(wild(a, action, ignore_case=True) for a in lst(stmt['Action']))
    elif 'NotAction' in stmt:
        ok = not any(wild(a, action, ignore_case=True) for a in lst(stmt['NotAction']))
    else:
        return False
    if not ok:
        return False
    if 'Resource' in stmt:
        ok = any(wild(r, resource) for r in lst(stmt['Resource']))
    elif 'NotResource' in stmt:
        ok = not any(wild(r, resource) for r in lst(stmt['NotResource']))
    else:
        ok = True   # SCP·신뢰 정책은 Resource 가 없을 수 있다
    return ok and _cond_ok(stmt.get('Condition'), ctx)


def decide(docs, action, resource='*', ctx=None):
    """자격 증명 기반 정책 평가: 명시적 Deny > Allow > 암묵적 거부('implicit')"""
    sts = [s for d in docs for s in statements(d)]
    if any(s.get('Effect') == 'Deny' and matches(s, action, resource, ctx) for s in sts):
        return 'deny'
    if any(s.get('Effect') == 'Allow' and matches(s, action, resource, ctx) for s in sts):
        return 'allow'
    return 'implicit'


def allowed(docs, action, resource='*', ctx=None):
    return decide(docs, action, resource, ctx) == 'allow'


def scp_decide(levels, action, ctx=None, resource='*'):
    """SCP: 루트 → OU → 계정 단계마다 Allow 가 하나는 있어야 하고, 어디든 Deny 가 걸리면 거부"""
    for docs in levels:
        d = decide(docs, action, resource, ctx)
        if d != 'allow':
            return 'deny'
    return 'allow'


def account_of(principal):
    """'arn:aws:iam::123456789012:root' / '123456789012' / '*' → 계정 ID (또는 '*')"""
    p = str(principal)
    if p == '*' or p.isdigit():
        return p
    parts = p.split(':')
    return parts[4] if len(parts) > 4 and parts[4] else p


def assume_principals(trust_doc, action='sts:AssumeRole'):
    """신뢰 정책에서 action 을 허용하는 (주체 종류, 주체 값, 문장) 목록. Principal "*" 는 ('AWS', '*')"""
    out = []
    for s in statements(trust_doc):
        if s.get('Effect') != 'Allow' or not any(wild(a, action, ignore_case=True) for a in lst(s.get('Action'))):
            continue
        p = s.get('Principal')
        if p == '*':
            out.append(('AWS', '*', s))
        elif isinstance(p, dict):
            for kind, vals in p.items():
                for v in lst(vals):
                    out.append((kind, v, s))
    return out
