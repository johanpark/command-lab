"""CloudWatch Logs 필터 패턴(자주 쓰는 일부)을 로그 줄에 적용해 본다.
사용: pattern_eval.py '패턴' events.json → 걸린 줄 수와 그중 진짜 ERROR 수"""
import json, re, sys


def json_match(expr, obj):
    # { $.a = "x" && $.b != y || ... } 의 단순한 형태
    expr = expr.strip()[1:-1].strip()
    def cond(c):
        c = c.strip().strip('()').strip()
        m = re.fullmatch(r'\$\.([\w.\[\]]+)\s*(=|!=)\s*(?:"([^"]*)"|(\S+))', c)
        if not m:
            raise ValueError(c)
        path, op, q, bare = m.groups()
        val = q if q is not None else bare
        cur = obj
        for k in path.split('.'):
            cur = cur.get(k) if isinstance(cur, dict) else None
        s = '' if cur is None else str(cur)
        if '*' in val:
            ok = re.fullmatch(re.escape(val).replace(r'\*', '.*'), s) is not None
        else:
            ok = s == val
        return ok if op == '=' else not ok
    return any(all(cond(c) for c in part.split('&&')) for part in expr.split('||'))


def term_match(pat, line):
    terms = re.findall(r'[?-]?"(?:\\.|[^"\\])*"|[?-]?\S+', pat)
    musts, anys, nots = [], [], []
    for t in terms:
        kind = t[0] if t[0] in '?-' else ''
        word = t[1:] if kind else t
        if len(word) >= 2 and word[0] == word[-1] == '"':
            word = re.sub(r'\\(.)', r'\1', word[1:-1])   # "..." 안의 \" 같은 이스케이프 풀기
        (anys if kind == '?' else nots if kind == '-' else musts).append(word)
    if any(w in line for w in nots):
        return False
    if musts and not all(w in line for w in musts):
        return False
    if anys and not any(w in line for w in anys):
        return False
    return True


pat = sys.argv[1]
events = json.load(open(sys.argv[2]))
hit = err = 0
for e in events:
    line = e['message']
    obj = json.loads(line)
    if pat.strip().startswith('{'):
        try:
            m = json_match(pat, obj)
        except ValueError as x:
            print(f'parse\t{x}'); sys.exit()
    elif pat.strip().startswith('['):
        print('parse\t공백 구분 패턴([...])은 JSON 로그에 맞지 않아요'); sys.exit()
    else:
        m = term_match(pat, line)
    if m:
        hit += 1
        err += obj.get('level') == 'ERROR'
print(f'{hit}\t{err}')
