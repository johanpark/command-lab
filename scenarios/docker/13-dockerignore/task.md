# 이미지가 왜 이렇게 커요? (.dockerignore)

정적 웹사이트 하나 띄우는 이미지 `webapp:1.0` 이 **수십 MB** 나 돼요. 배포할 때마다 업로드가 한참 걸려요. 게다가 보안팀이 이렇게 알려 왔어요.

> "webapp 이미지 안에서 `.env` 파일(DB 비밀번호)이 보입니다. 이미지를 받은 사람은 누구나 볼 수 있어요."

프로젝트는 `~/webapp` 에 있어요. `Dockerfile` 은 `COPY . .` 로 폴더를 통째로 넣고 있어요. 실제로 서비스에 필요한 건 `public/` 폴더뿐이에요.

## 목표
1. **`webapp:1.1`** 이미지를 새로 빌드하세요.
2. 이미지 안(`/app`)에 **`.env`, `.git`, `node_modules`, `logs`** 가 **없어야** 해요.
3. 이미지 크기는 **10MB 미만**이어야 해요.
4. 웹사이트는 그대로 동작해야 해요. (`/app/public/index.html` 이 있어야 함)

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `docker images` | 이미지 목록과 크기 |
| `docker run --rm webapp:1.0 ls -la /app` | 이미지 안에 뭐가 들었나 |
| `du -sh ~/webapp/* ~/webapp/.[!.]*` | 폴더별 크기 (숨김 포함) |
| `nano ~/webapp/.dockerignore` | 빌드할 때 **보내지 않을** 파일 목록 |
| `docker build -t webapp:1.1 ~/webapp` | 빌드 |
| `docker history webapp:1.1` | 층(layer)별 크기 |
