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

# S3: get-bucket-replication 이 접두사·태그 필터, 저장 클래스, 삭제 마커 설정을 무시하고 늘 빈 값으로 돌려준다
#     → 저장된 실제 값을 그대로 보여 주도록 응답 템플릿을 고친다
p = pathlib.Path(importlib.util.find_spec('moto.s3.responses').origin)
s = p.read_text()
OLD_RULE = '''  <DeleteMarkerReplication>
    <Status>Disabled</Status>
  </DeleteMarkerReplication>
  <Filter>
    <Prefix></Prefix>
  </Filter>
  <Destination>
    <Bucket>{{ rule["Destination"]["Bucket"] }}</Bucket>
  </Destination>'''
NEW_RULE = '''  {# cmdlab #}
  <DeleteMarkerReplication>
    <Status>{{ (rule.get("DeleteMarkerReplication") or {}).get("Status") or "Disabled" }}</Status>
  </DeleteMarkerReplication>
  {% if rule.get("Filter") is mapping %}{% set f = rule["Filter"] %}
  <Filter>
    {% if f.get("And") is mapping %}{% set tags = f["And"].get("Tag") or [] %}{% if tags is mapping %}{% set tags = [tags] %}{% endif %}
    <And>{% if f["And"].get("Prefix") is not none %}<Prefix>{{ f["And"]["Prefix"] or "" }}</Prefix>{% endif %}
      {% for t in tags %}<Tag><Key>{{ t["Key"] }}</Key><Value>{{ t["Value"] }}</Value></Tag>{% endfor %}</And>
    {% elif f.get("Tag") is mapping %}<Tag><Key>{{ f["Tag"]["Key"] }}</Key><Value>{{ f["Tag"]["Value"] }}</Value></Tag>
    {% else %}<Prefix>{{ f.get("Prefix") or "" }}</Prefix>{% endif %}
  </Filter>
  {% elif "Prefix" in rule %}
  <Prefix>{{ rule["Prefix"] or "" }}</Prefix>
  {% else %}
  <Filter><Prefix></Prefix></Filter>
  {% endif %}
  <Destination>
    <Bucket>{{ rule["Destination"]["Bucket"] }}</Bucket>
    {% if rule["Destination"].get("StorageClass") %}<StorageClass>{{ rule["Destination"]["StorageClass"] }}</StorageClass>{% endif %}
  </Destination>'''
if '{# cmdlab #}' not in s:
    assert OLD_RULE in s, 'moto s3 복제 템플릿이 예상과 달라요'
    p.write_text(s.replace(OLD_RULE, NEW_RULE))
print('patched', p)

# CloudWatch Logs: 같은 로그 그룹에 같은 이름으로 put-metric-filter 를 다시 하면 고치지 않고 하나 더 쌓는다
#                  (실제 AWS 는 기존 필터를 새 값으로 바꾼다) → 오타를 고쳐 다시 저장한 학습자가 채점에서 막힘
p = pathlib.Path(importlib.util.find_spec('moto.logs.metric_filters').origin)
s = p.read_text()
OLD_ADD = '''    ) -> None:
        self.metric_filters.append('''
NEW_ADD = '''    ) -> None:
        self.metric_filters = [f for f in self.metric_filters  # cmdlab: 같은 이름은 바꿔 쓰기
                               if not (f["filterName"] == filter_name and f["logGroupName"] == log_group_name)]
        self.metric_filters.append('''
if '# cmdlab' not in s:
    assert OLD_ADD in s, 'moto 지표 필터 코드가 예상과 달라요'
    p.write_text(s.replace(OLD_ADD, NEW_ADD))
print('patched', p)

# EC2: 연결된 Elastic IP 도 release-address 로 바로 반납된다 (실제 AWS 는 InvalidIPAddress.InUse 로 거부)
#      → NAT 게이트웨이·운영 서버의 주소를 "안 쓰는 것" 으로 착각해 반납해도 아무 경고 없이 사라짐
p = pathlib.Path(importlib.util.find_spec('moto.ec2.models.elastic_ip_addresses').origin)
s = p.read_text()
EIP = '''

# --- cmdlab: 연결된 주소는 반납 거부 (실제 AWS 처럼) ---
_cl_orig_release_address = ElasticAddressBackend.release_address


def _cl_release_address(self, address=None, allocation_id=None):
    from ..exceptions import EC2ClientError
    eips = self.address_by_ip([address]) if address else self.address_by_allocation([allocation_id]) if allocation_id else []
    if eips and (eips[0].association_id or eips[0].instance or eips[0].eni):
        raise EC2ClientError('InvalidIPAddress.InUse', f'Address {allocation_id or address} is in use.')
    return _cl_orig_release_address(self, address=address, allocation_id=allocation_id)


ElasticAddressBackend.release_address = _cl_release_address
'''
if 'cmdlab: 연결된 주소는' not in s:
    assert 'def release_address' in s, 'moto EIP 코드가 예상과 달라요'
    p.write_text(s + EIP)
print('patched', p)

# CloudWatch Logs: put-retention-policy 가 아무 숫자나 받는다 (실제 AWS 는 정해진 값만: 1, 3, 5, 7, 14, 30, ...)
p = pathlib.Path(importlib.util.find_spec('moto.logs.models').origin)
s = p.read_text()
RET = '''

# --- cmdlab: 보존 기간은 정해진 값만 (실제 AWS 처럼) ---
_CL_RETENTION = [1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653]
_cl_orig_put_retention_policy = LogsBackend.put_retention_policy


def _cl_put_retention_policy(self, log_group_name, retention_in_days):
    from moto.logs.exceptions import InvalidParameterException
    if int(retention_in_days) not in _CL_RETENTION:
        raise InvalidParameterException(
            msg=f"1 validation error detected: Value '{retention_in_days}' at 'retentionInDays' failed to satisfy constraint: "
                f"Member must satisfy enum value set: {_CL_RETENTION}")
    return _cl_orig_put_retention_policy(self, log_group_name, retention_in_days)


LogsBackend.put_retention_policy = _cl_put_retention_policy
'''
if 'cmdlab: 보존 기간은' not in s:
    assert 'def put_retention_policy' in s, 'moto logs 코드가 예상과 달라요'
    p.write_text(s + RET)
print('patched', p)

# Backup: (1) update-backup-plan 이 없어서 500 에러 (2) 지운 계획과 같은 이름으로 다시 만들 수 없음
#         → 규칙을 고치려던 학습자가 막힘
p = pathlib.Path(importlib.util.find_spec('moto.backup.models').origin)
s = p.read_text()
BK = '''

# --- cmdlab: 지운 계획 이름은 다시 쓸 수 있게, update-backup-plan 지원 ---
def _cl_create_backup_plan(self, backup_plan, backup_plan_tags, creator_request_id):
    if any(p.deletion_date is None and p.backup_plan["BackupPlanName"] == backup_plan["BackupPlanName"] for p in self.plans.values()):
        raise AlreadyExistsException(msg="Backup plan with the same plan document already exists")
    plan = Plan(backup_plan=backup_plan, creator_request_id=creator_request_id, backend=self)
    if backup_plan_tags:
        self.tag_resource(plan.backup_plan_arn, backup_plan_tags)
    self.plans[plan.backup_plan_id] = plan
    return plan


def _cl_update_backup_plan(self, backup_plan_id, backup_plan):
    old = self.plans.get(backup_plan_id)
    if old is None or old.deletion_date is not None:
        raise ResourceNotFoundException(msg="Failed reading Backup plan with provided version")
    new = Plan(backup_plan=backup_plan, creator_request_id=old.creator_request_id, backend=self)
    new.backup_plan_id, new.backup_plan_arn, new.creation_date = old.backup_plan_id, old.backup_plan_arn, old.creation_date
    self.plans[backup_plan_id] = new
    return new


BackupBackend.create_backup_plan = _cl_create_backup_plan
BackupBackend.update_backup_plan = _cl_update_backup_plan
'''
if 'cmdlab: 지운 계획' not in s:
    assert 'class BackupBackend' in s and 'class Plan' in s, 'moto backup 코드가 예상과 달라요'
    p.write_text(s + BK)
p = pathlib.Path(importlib.util.find_spec('moto.backup.responses').origin)
s = p.read_text()
BKR = '''

# --- cmdlab: update-backup-plan ---
def _cl_update_backup_plan_response(self):
    params = json.loads(self.body)
    plan_id = [x for x in self.path.split("/") if x][-1]
    plan = self.backup_backend.update_backup_plan(plan_id, params.get("BackupPlan"))
    return json.dumps(dict(plan.to_dict()))


BackupResponse.update_backup_plan = _cl_update_backup_plan_response
'''
if 'cmdlab: update-backup-plan' not in s:
    assert 'class BackupResponse' in s and 'import json' in s, 'moto backup 응답 코드가 예상과 달라요'
    p.write_text(s + BKR)
print('patched', p)
