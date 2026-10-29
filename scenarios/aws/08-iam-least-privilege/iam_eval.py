"""report-bot 의 실제 권한을 간단히 계산한다 (Allow 문장만, 와일드카드 지원).

사용법: python3 iam_eval.py 버킷 다른버킷  → 한 줄에 '결과<TAB>설명'
"""
import fnmatch, json, subprocess, sys

bucket, other = sys.argv[1], sys.argv[2]
user = "report-bot"


def aws(*args):
    out = subprocess.run(["aws", *args, "--output", "json"], capture_output=True, text=True)
    return json.loads(out.stdout or "null")


docs = []
for p in (aws("iam", "list-attached-user-policies", "--user-name", user) or {}).get("AttachedPolicies", []):
    pol = aws("iam", "get-policy", "--policy-arn", p["PolicyArn"])["Policy"]
    ver = aws("iam", "get-policy-version", "--policy-arn", p["PolicyArn"], "--version-id", pol["DefaultVersionId"])
    docs.append((p["PolicyName"], ver["PolicyVersion"]["Document"]))
for name in (aws("iam", "list-user-policies", "--user-name", user) or {}).get("PolicyNames", []):
    docs.append((name, aws("iam", "get-user-policy", "--user-name", user, "--policy-name", name)["PolicyDocument"]))

broad = False
statements = []
for name, doc in docs:
    if isinstance(doc, str):
        doc = json.loads(doc)
    st = doc.get("Statement", [])
    for s in st if isinstance(st, list) else [st]:
        if s.get("Effect") != "Allow":
            continue
        if "NotAction" in s or "NotResource" in s:
            broad = True
            continue
        acts = s.get("Action", []); res = s.get("Resource", [])
        statements.append(([acts] if isinstance(acts, str) else acts, [res] if isinstance(res, str) else res))


def allowed(action, resource):
    if broad:
        return True
    for acts, res in statements:
        if any(fnmatch.fnmatchcase(action.lower(), a.lower()) for a in acts) and any(fnmatch.fnmatchcase(resource, r) for r in res):
            return True
    return False


attached = [n for n, _ in docs]
print(("ok" if "AdministratorAccess" not in attached else "no") + "\tAdministratorAccess 를 뗐다")
need = [("s3:ListBucket", f"arn:aws:s3:::{bucket}", "보고서 버킷의 파일 목록을 볼 수 있다 (s3:ListBucket → 버킷 ARN)"),
        ("s3:GetObject", f"arn:aws:s3:::{bucket}/2026/10/daily.csv", "보고서 버킷의 파일을 읽을 수 있다 (s3:GetObject → 버킷/*)")]
for a, r, msg in need:
    print(("ok" if allowed(a, r) else "no") + "\t" + msg)
deny = [("s3:PutObject", f"arn:aws:s3:::{bucket}/x.csv"), ("s3:DeleteObject", f"arn:aws:s3:::{bucket}/2026/10/daily.csv"),
        ("s3:DeleteBucket", f"arn:aws:s3:::{bucket}"), ("s3:PutBucketPolicy", f"arn:aws:s3:::{bucket}")]
bad = [a for a, r in deny if allowed(a, r)]
print(("ok" if not bad else "no") + "\t보고서 버킷에 쓰기·삭제는 못 한다" + (f" (지금 허용됨: {', '.join(bad)})" if bad else ""))
oth = [("s3:GetObject", f"arn:aws:s3:::{other}/salary.csv"), ("s3:ListBucket", f"arn:aws:s3:::{other}")]
bad = [a for a, r in oth if allowed(a, r)]
print(("ok" if not bad else "no") + "\t다른 버킷(finance)은 못 본다" + (" (Resource 가 너무 넓어요)" if bad else ""))
svc = [("iam:CreateUser", "*"), ("ec2:TerminateInstances", "*"), ("secretsmanager:GetSecretValue", "*")]
bad = [a for a, r in svc if allowed(a, r)]
print(("ok" if not bad else "no") + "\t다른 서비스(IAM, EC2, Secrets Manager)는 못 쓴다" + (f" (지금 허용됨: {', '.join(bad)})" if bad else ""))
