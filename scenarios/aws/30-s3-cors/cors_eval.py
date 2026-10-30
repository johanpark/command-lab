"""S3 CORS 설정에 브라우저 요청 몇 가지를 흉내 내 본다. 출력: 줄마다 ok|no<TAB>설명"""
import fnmatch, json, sys

rules = json.load(sys.stdin).get('CORSRules', [])


def lower(xs):
    return [x.lower() for x in xs or []]


def find(origin, method, headers=()):
    for r in rules:
        if not any(fnmatch.fnmatchcase(origin, o) for o in r.get('AllowedOrigins', [])):
            continue
        if method not in r.get('AllowedMethods', []):
            continue
        ah = lower(r.get('AllowedHeaders'))
        if all(any(fnmatch.fnmatchcase(h.lower(), a) for a in ah) for h in headers):
            return r
    return None


def say(ok, msg):
    print(('ok' if ok else 'no') + '\t' + msg)


for o in ('https://shop.example', 'https://admin.shop.example'):
    for m in ('GET', 'PUT'):
        hd = ('content-type',) if m == 'PUT' else ()
        r = find(o, m, hd)
        say(r is not None, f'{o} 에서 {m}{" (Content-Type 포함)" if hd else ""} 허용')
        if m == 'PUT' and r is not None:
            say('etag' in lower(r.get('ExposeHeaders')), f'{o} 의 PUT 응답에서 ETag 를 읽을 수 있음')
bad = []
if find('http://localhost:3000', 'GET') or find('http://localhost:3000', 'PUT', ('content-type',)):
    bad.append('localhost:3000 이 아직 허용됨')
if any('*' == o.strip() for r in rules for o in r.get('AllowedOrigins', [])) or find('https://evil.example', 'GET'):
    bad.append('아무 사이트나(*) 허용됨')
if any(find(o, m) for o in ('https://shop.example', 'https://admin.shop.example') for m in ('DELETE', 'POST')):
    bad.append('DELETE/POST 까지 허용됨')
say(not bad, '필요한 것만 허용' + (f' ({", ".join(bad)})' if bad else ''))
