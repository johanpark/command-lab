# 브라우저에서 S3 업로드가 CORS 에러로 막혀요 (S3 CORS)

운영 사이트에서 프로필 사진 업로드를 누르면 실패해요. 브라우저 콘솔 에러와 프론트엔드 메모는 `~/cors-error.txt` 에 있어요.

브라우저는 **다른 도메인**(shop.example → s3.amazonaws.com)으로 요청할 때 먼저 "보내도 되나요?" 를 물어봐요(**프리플라이트**).
S3 버킷의 **CORS 설정**이 그 질문에 "예" 라고 답해야 요청이 나가요.

## 목표
업로드 버킷(`shop-uploads-` 로 시작)의 CORS 설정을 고쳐서:
1. **`https://shop.example`** 과 **`https://admin.shop.example`** 에서 **GET, PUT** 요청을 허용하세요.
2. 브라우저가 보내는 **`Content-Type`** 헤더를 허용하세요.
3. 브라우저가 응답의 **`ETag`** 헤더를 읽을 수 있게 하세요.
4. **`localhost:3000`** 은 빼고, **아무 사이트나(`*`) 허용하지 마세요.** DELETE 같은 다른 메서드도 열지 마세요.
5. 버킷은 계속 비공개여야 해요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws s3api get-bucket-cors --bucket 버킷` | 지금 CORS 설정 |
| `aws s3api put-bucket-cors --bucket 버킷 --cors-configuration file://cors.json` | CORS 설정 바꾸기 (통째로 교체) |

`cors.json` 모양:
```json
{"CORSRules": [{
  "AllowedOrigins": ["https://..."],
  "AllowedMethods": ["GET"],
  "AllowedHeaders": ["..."],
  "ExposeHeaders": ["..."],
  "MaxAgeSeconds": 3000
}]}
```
