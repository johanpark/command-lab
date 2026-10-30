"""moto 가 실제 AWS 와 다르게 동작해서 학습자를 헷갈리게 하는 곳을 고친다 (이미지 빌드 때 한 번 실행)."""
import importlib.util
import pathlib

# ECR: list-images / describe-images 의 --filter tagStatus=TAGGED|UNTAGGED 를 무시하고 전부 돌려준다
#      → 태그 없는 것만 지우려던 학습자가 운영 이미지까지 지우게 됨
p = pathlib.Path(importlib.util.find_spec('moto.ecr.responses').origin)
s = p.read_text()
FILTER = '''
        _ts = (self._get_param("filter") or {}).get("tagStatus")  # cmdlab
        if _ts == "TAGGED":
            images = [i for i in images if i.image_tags]
        elif _ts == "UNTAGGED":
            images = [i for i in images if not i.image_tags]
'''
targets = [
    '        images = self.ecr_backend.list_images(repository_str, registry_id)\n',
    '        images = self.ecr_backend.describe_images(\n            repository_str, registry_id, image_ids\n        )\n',
]
if '# cmdlab' not in s:
    for t in targets:
        assert t in s, f'moto 코드가 예상과 달라요: {t!r}'
        s = s.replace(t, t + FILTER.lstrip('\n'))
    p.write_text(s)
print('patched', p)

# CloudWatch Logs: filter-log-events 가 JSON 필터({ $.level = "ERROR" })를 모르고 모든 줄을 돌려준다
#                  → 지표 필터 실습에서 힌트대로 미리 보기를 하면 160줄이 다 나와 헷갈림
p = pathlib.Path(importlib.util.find_spec('moto.logs.utils').origin)
s = p.read_text()
LOGS = r'''

# --- cmdlab: 실제 CloudWatch Logs 필터 패턴에 가깝게 (JSON 조건, - 제외, ? 하나라도) ---
import json as _cl_json
import re as _cl_re


def _cl_json_match(expr, obj):
    expr = expr.strip()[1:-1].strip()

    def cond(c):
        c = c.strip().strip('()').strip()
        m = _cl_re.fullmatch(r'\$\.([\w.]+)\s*(=|!=|>=|<=|>|<)\s*(?:"([^"]*)"|(\S+))', c)
        if not m:
            raise ValueError(c)
        path, op, q, bare = m.groups()
        cur = obj
        for k in path.split('.'):
            cur = cur.get(k) if isinstance(cur, dict) else None
        if op in ('>', '<', '>=', '<='):
            try:
                a, b = float(cur), float(bare if q is None else q)
            except (TypeError, ValueError):
                return False
            return {'>': a > b, '<': a < b, '>=': a >= b, '<=': a <= b}[op]
        val = q if q is not None else bare
        s = '' if cur is None else (str(cur).lower() if isinstance(cur, bool) else str(cur))
        ok = (_cl_re.fullmatch(_cl_re.escape(val).replace(r'\*', '.*'), s) is not None) if '*' in val else s == val
        return ok if op == '=' else not ok
    return any(all(cond(c) for c in part.split('&&')) for part in expr.split('||'))


def _cl_term_match(pat, line):
    musts, anys, nots = [], [], []
    for t in _cl_re.findall(r'[?-]?"(?:\\.|[^"\\])*"|[?-]?\S+', pat):
        kind = t[0] if t[0] in '?-' else ''
        word = t[1:] if kind else t
        if len(word) >= 2 and word[0] == word[-1] == '"':
            word = _cl_re.sub(r'\\(.)', r'\1', word[1:-1])
        (anys if kind == '?' else nots if kind == '-' else musts).append(word)
    if any(w in line for w in nots):
        return False
    if musts and not all(w in line for w in musts):
        return False
    return not anys or any(w in line for w in anys)


class EventMessageFilter:  # noqa: F811  (위의 원래 클래스를 덮어쓴다)
    def __init__(self, pattern):
        self.pattern = (pattern or '').strip()

    def matches(self, message):
        p = self.pattern
        if not p:
            return True
        if p.startswith('{'):
            try:
                return _cl_json_match(p, _cl_json.loads(message))
            except (ValueError, AttributeError):
                return False
        if p.startswith('['):
            return True   # 공백 구분 패턴은 아직 흉내 내지 않음
        return _cl_term_match(p, message)
'''
if 'cmdlab: 실제 CloudWatch Logs' not in s:
    assert 'class EventMessageFilter' in s, 'moto logs 코드가 예상과 달라요'
    p.write_text(s + LOGS)
print('patched', p)
