# 해설

```bash
find /srv/www -type d -exec chmod 755 {} +
find /srv/www -type f -exec chmod 644 {} +
chmod 755 /srv/www/bin/*.sh
chmod 640 /srv/www/config/secret.php
find /srv/www -exec stat -c '%a %n' {} +    # 확인
```

## 숫자 권한 읽는 법
```
7 5 5        r=4  w=2  x=1
│ │ └ 다른 사람: r-x (4+1)
│ └── 그룹:      r-x (4+1)
└──── 소유자:    rwx (4+2+1)
```
폴더의 `x` 는 "들어갈 수 있음", 파일의 `x` 는 "실행할 수 있음" 이라 뜻이 달라요. 그래서 폴더와 파일을 같은 숫자로 맞추면 안 돼요.

## 대문자 X 의 함정
`chmod -R u=rwX,go=rX /srv/www` 는 "폴더와 **이미 실행 권한이 있는 파일**에만 x" 라서 보통은 편리해요. 그런데 이번처럼 모든 파일이 이미 777 이면 **전부 실행 파일로 남아요.** 777 을 되돌릴 땐 `find -type` 이 확실해요.

## 777 대신 했어야 할 것
업로드가 안 됐던 진짜 원인은 대개 **업로드 폴더 하나**의 소유자·그룹 문제예요.
```bash
sudo chgrp www-data /srv/www/uploads
sudo chmod 2775 /srv/www/uploads    # 그룹 쓰기 + setgid (새 파일도 같은 그룹)
```
필요한 곳에만, 필요한 사람에게만. **777 은 거의 항상 틀린 답**이에요.
