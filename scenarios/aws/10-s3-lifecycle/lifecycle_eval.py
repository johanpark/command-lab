"""버킷의 수명 주기 규칙을 예시 경로에 적용해 보고 결과를 한 줄씩 출력한다."""
import json, subprocess, sys

bucket = sys.argv[1]
out = subprocess.run(["aws", "s3api", "get-bucket-lifecycle-configuration", "--bucket", bucket, "--output", "json"],
                     capture_output=True, text=True)
rules = json.loads(out.stdout).get("Rules", []) if out.returncode == 0 and out.stdout else []
if not rules:
    print("no\t수명 주기 규칙이 걸려 있다 (아직 규칙이 없어요)")
    sys.exit()
print("ok\t수명 주기 규칙이 걸려 있다")


def prefix_of(r):
    f = r.get("Filter")
    if f is None:
        return r.get("Prefix", "")
    if "Prefix" in f:
        return f["Prefix"]
    if "And" in f:
        return f["And"].get("Prefix", "")
    return None if "Tag" in f else ""


def effect(key):
    """그 경로에 적용되는 (전환 일수, 등급), 삭제 일수 — 가장 이른 것."""
    trans, exp = [], []
    for r in rules:
        if r.get("Status") != "Enabled":
            continue
        p = prefix_of(r)
        if p is None or not key.startswith(p):
            continue
        for t in r.get("Transitions", []):
            if "Days" in t:
                trans.append((t["Days"], t.get("StorageClass")))
        if "Days" in r.get("Expiration", {}):
            exp.append(r["Expiration"]["Days"])
    return (min(trans) if trans else None), (min(exp) if exp else None)


t, e = effect("logs/app/2025-10-01.log.gz")
t2, e2 = effect("logs/nginx/2025-10-01.log.gz")
ok = t == (30, "GLACIER") and e == 365 and (t2, e2) == (t, e)
why = "" if ok else (" (logs/ 규칙이 없어요 — put 은 기존 규칙을 통째로 덮어써요)" if t is None and e is None else f" (지금 logs/app: 전환={t}, 삭제={e})")
print(("ok" if ok else "no") + "\tlogs/ : 30일 뒤 GLACIER, 365일 뒤 삭제" + why)
t, e = effect("tmp/upload-1.part")
ok = e == 7
why = "" if ok else (" (tmp/ 규칙이 없어요 — put 은 기존 규칙을 통째로 덮어써서, 따로 두 번 넣으면 앞의 것이 사라져요)" if e is None else f" (지금 {e}일 뒤 삭제)")
print(("ok" if ok else "no") + "\ttmp/ : 7일 뒤 삭제" + why)
t, e = effect("backups/db-2025-12-31.sql.gz")
ok = t is None and e is None
print(("ok" if ok else "no") + "\tbackups/ 는 자동으로 옮기거나 지우지 않는다" + ("" if ok else f" (지금 전환={t}, 삭제={e} — Prefix 가 비어 있거나 너무 넓은 규칙이 있어요!)"))
