"""ECR 수명 주기 정책을 이미지 목록에 적용해 보고 결과를 설명한다.
사용: ecr_eval.py 정책.json 이미지목록(digest<TAB>나이<TAB>태그,태그)
출력: ok|no<TAB>설명 줄들"""
import json, sys, fnmatch

policy = json.load(open(sys.argv[1]))
images = []
for line in open(sys.argv[2]):
    d, age, tags = line.rstrip('\n').split('\t')
    images.append({'d': d, 'age': int(age), 'tags': [t for t in tags.split(',') if t]})


def matches(sel, img):
    st = sel.get('tagStatus')
    if st == 'untagged':
        return not img['tags']
    if st == 'any':
        return True
    if st == 'tagged':
        if not img['tags']:
            return False
        pre, pat = sel.get('tagPrefixList') or [], sel.get('tagPatternList') or []
        if not pre and not pat:
            return False   # 실제 ECR 은 tagged 에 접두사/패턴이 필수
        return any(t.startswith(p) for t in img['tags'] for p in pre) or \
               any(fnmatch.fnmatchcase(t, p) for t in img['tags'] for p in pat)
    return False


rules = sorted(policy.get('rules', []), key=lambda r: r.get('rulePriority', 0))
claimed, expired = set(), set()
for r in rules:
    sel = r.get('selection', {})
    cand = [i for i in images if i['d'] not in claimed and matches(sel, i)]
    for i in cand:
        claimed.add(i['d'])
    if r.get('action', {}).get('type') != 'expire':
        continue
    n = int(sel.get('countNumber', 0))
    if sel.get('countType') == 'sinceImagePushed':
        mult = {'days': 1}.get(sel.get('countUnit', 'days'), 1)
        expired |= {i['d'] for i in cand if i['age'] > n * mult}
    elif sel.get('countType') == 'imageCountMoreThan':
        newest = sorted(cand, key=lambda i: i['age'])
        expired |= {i['d'] for i in newest[n:]}


def label(i):
    return ','.join(i['tags']) or '(태그 없음)'


problems = []
for i in images:
    tags, age, gone = i['tags'], i['age'], i['d'] in expired
    if not tags:
        want = age > 1; kind = f'태그 없는 {age}일 된 이미지'
    elif any(t.startswith('dev-') for t in tags):
        want = age > 14; kind = f'{label(i)} ({age}일)'
    elif 'prod' in tags:
        want = False; kind = f'{label(i)} (운영 중!)'
    elif any(t.startswith('release-') for t in tags):
        rel = sorted([x for x in images if any(t.startswith('release-') for t in x['tags'])], key=lambda x: x['age'])
        want = i not in rel[:10]; kind = f'{label(i)}'
    else:
        want = False; kind = label(i)
    if gone and not want:
        problems.append(f'지우면 안 되는 {kind} 이(가) 지워져요')
    elif want and not gone:
        problems.append(f'지워야 할 {kind} 이(가) 남아요')
print('ok' if not problems else 'no')
for p in problems[:4]:
    print(p)
if len(problems) > 4:
    print(f'... 외 {len(problems) - 4}건')
