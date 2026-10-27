# 해설

```bash
curl -v -m 3 http://api.internal:8000/health   # *   Trying 10.x.x.x:8000...
getent hosts api.internal                      # 10.x.x.x  api.internal
cat /etc/hosts                                 # 옛 IDC IP 가 수동으로 박혀 있음
getent hosts api.internal | awk '{print $1}' > ~/answer.txt
sudo nano /etc/hosts                           # 10.x.x.x → 127.0.0.1
curl http://api.internal:8000/health           # ok
```

## 이름 풀이 순서
```
curl api.internal
   │
   ├─ 1. /etc/hosts          ← 여기 적혀 있으면 DNS 는 보지도 않음
   └─ 2. DNS (/etc/resolv.conf 의 서버)
```
(순서는 `/etc/nsswitch.conf` 의 `hosts: files dns` 줄이 정해요)

## 기억할 것
- "이 서버에서만 안 돼요" → 그 서버의 `/etc/hosts` 를 의심하세요. 임시로 넣어 둔 줄이 이사 후에도 남아 있는 경우가 정말 많아요.
- `ping`, `nslookup`, `dig` 는 **DNS 만** 보는 도구라서 `/etc/hosts` 문제를 못 볼 수 있어요. 시스템이 실제로 쓰는 결과는 `getent hosts` 가 정확합니다.
- Windows 에도 같은 파일이 있어요: `C:\Windows\System32\drivers\etc\hosts`
