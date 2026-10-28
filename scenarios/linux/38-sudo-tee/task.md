# sudo 를 붙였는데도 Permission denied

새 사무실 IP 를 서버 접근 허용 목록에 추가해 달라는 요청(`~/request.txt`)이 왔어요. 허용 목록은 root 만 쓸 수 있는 `/etc/app/allowed_ips` 예요. 그래서 `sudo` 를 붙였는데...

```
$ sudo echo "203.0.113.7" >> /etc/app/allowed_ips
-bash: /etc/app/allowed_ips: Permission denied
```

## 목표
1. `~/request.txt` 의 **IP 들을 `/etc/app/allowed_ips` 맨 뒤에 추가**하세요. (한 줄에 하나, 각각 **한 번씩만**)
2. 기존 허용 목록은 **한 줄도 사라지면 안 돼요.**
3. 점검 공지 파일 `/etc/app/maintenance.conf` 를 아래 내용 **그대로** 새로 만드세요.
   ```
   MAINTENANCE=on
   UNTIL=06:00
   ```
4. 두 파일 모두 소유자는 **root** 여야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `sudo 명령` | 명령을 root 권한으로 실행 |
| `명령 \| sudo tee 파일` | 출력을 root 권한으로 파일에 쓰기 (**덮어쓰기**) |
| `명령 \| sudo tee -a 파일` | 출력을 root 권한으로 파일 끝에 **추가** |
| `sudo sh -c 'echo ... >> 파일'` | 리다이렉션까지 통째로 root 로 |
| `ls -l 파일` | 소유자 확인 |
