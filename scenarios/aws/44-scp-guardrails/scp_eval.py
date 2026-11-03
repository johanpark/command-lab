"""SCP 묶음을 실제 AWS 규칙대로 평가한다 (공용 policy.py 의 scp_decide).
입력(JSON): {"levels": {"이름": [[루트 SCP 문서...], [OU ...], [계정 ...]], ...},
             "cases": [[id("이름:번호"), action, region, instanceType|null], ...]}
출력: 한 줄에 "id<TAB>allow|deny" (모르는 조건 연산자면 "ERR<TAB>설명")"""
import json, sys

import policy

req = json.load(sys.stdin)
for cid, action, region, itype in req['cases']:
    ctx = {'aws:RequestedRegion': region}
    if itype:
        ctx['ec2:InstanceType'] = itype
    # RunInstances 는 실제로 인스턴스 ARN 에 대해 평가된다 (ec2:InstanceType 조건이 붙는 곳)
    res = f'arn:aws:ec2:{region}:210987654321:instance/i-0123456789abcdef0' if action.lower() == 'ec2:runinstances' else '*'
    try:
        print(f"{cid}\t{policy.scp_decide(req['levels'][cid.split(':')[0]], action, ctx, resource=res)}")
    except ValueError as e:
        print(f'ERR\t{e}'); break
