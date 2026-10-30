# 쌓여만 가는 컨테이너 이미지 정리 (ECR 수명 주기 정책)

배포할 때마다 `shop-api` 저장소에 이미지가 쌓여서, 매달 ECR 저장 요금이 늘고 있어요.
팀에서 정한 보관 규칙은 `~/ecr-policy.md` 에 있어요.

## 목표
1. `shop-api` 의 **태그 없는(untagged) 이미지를 지금 모두 지우세요.** 태그 있는 이미지는 지우지 마세요.
2. `shop-api` 에 **수명 주기 정책(lifecycle policy)** 을 걸어서, 앞으로는 규칙대로 자동 정리되게 하세요.
   - 태그 없는 이미지: 푸시 후 **1일**
   - `dev-` 이미지: 푸시 후 **14일**
   - `release-` 이미지: **최근 10개만** 유지
   - `prod` 같은 다른 태그는 규칙으로 지워지면 안 돼요.
3. `shop-web` 저장소는 건드리지 마세요.

## 써볼 명령어
| 명령어 | 하는 일 |
|---|---|
| `aws ecr describe-images --repository-name shop-api --query "imageDetails[].[imageTags,imagePushedAt]"` | 이미지 목록 |
| `aws ecr list-images --repository-name shop-api --filter tagStatus=UNTAGGED` | 태그 없는 이미지만 |
| `aws ecr batch-delete-image --repository-name shop-api --image-ids imageDigest=sha256:... imageDigest=...` | 이미지 지우기 |
| `aws ecr put-lifecycle-policy --repository-name shop-api --lifecycle-policy-text file://policy.json` | 수명 주기 정책 걸기 |
| `aws ecr get-lifecycle-policy --repository-name shop-api` | 확인 |

정책 모양:
```json
{"rules": [
  {"rulePriority": 1, "description": "설명",
   "selection": {"tagStatus": "untagged|tagged|any", "tagPrefixList": ["dev-"],
                 "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 14},
   "action": {"type": "expire"}}
]}
```
`countType` 은 `sinceImagePushed`(며칠 지난 것) 또는 `imageCountMoreThan`(N개 넘는 것, 이때는 countUnit 없음) 이에요.
