# 해설

```bash
# 1) 지금 쌓인 태그 없는 이미지 정리
ids=$(aws ecr list-images --repository-name shop-api --filter tagStatus=UNTAGGED --query 'imageIds[].imageDigest' --output text)
aws ecr batch-delete-image --repository-name shop-api --image-ids $(for d in $ids; do echo imageDigest=$d; done)

# 2) 앞으로는 자동으로
aws ecr put-lifecycle-policy --repository-name shop-api --lifecycle-policy-text file://policy.json
```
```json
{"rules": [
  {"rulePriority": 1, "selection": {"tagStatus": "untagged", "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 1}, "action": {"type": "expire"}},
  {"rulePriority": 2, "selection": {"tagStatus": "tagged", "tagPrefixList": ["dev-"], "countType": "sinceImagePushed", "countUnit": "days", "countNumber": 14}, "action": {"type": "expire"}},
  {"rulePriority": 3, "selection": {"tagStatus": "tagged", "tagPrefixList": ["release-"], "countType": "imageCountMoreThan", "countNumber": 10}, "action": {"type": "expire"}}
]}
```

## 태그 없는 이미지는 왜 생기나
`latest` 나 `prod` 처럼 **같은 태그로 새 이미지를 푸시하면**, 태그가 새 이미지로 옮겨 가고 이전 이미지는 **태그 없는 이미지**로 남아요. 아무도 안 쓰는데 요금만 나가요.

## 규칙이 적용되는 방식
- 규칙은 `rulePriority` 가 **작은 것부터** 봐요. 이미지는 **처음 걸린 규칙 하나**에만 속하고, 아래 규칙은 그 이미지를 보지 않아요.
- `imageCountMoreThan 10` 은 그 규칙에 걸린 이미지를 **푸시 시각 최신순**으로 세서 10개 넘는 것을 지워요.
- `tagStatus: any` 규칙은 **모든 이미지**(prod 포함)를 대상으로 해서 위험해요. 쓰려면 반드시 가장 낮은 우선순위(가장 큰 숫자)로 두고, 지켜야 할 이미지를 위 규칙들이 먼저 잡게 해야 해요.

## 실무 팁
- 정책을 걸기 전에 콘솔의 **"수명 주기 규칙 미리 보기"**(`aws ecr start-lifecycle-policy-preview`)로 무엇이 지워질지 꼭 확인하세요. 오늘 채점이 한 일과 같아요.
- 실제 정리는 정책을 건 뒤 **최대 24시간** 안에 돌아요. 그래서 지금 당장 줄여야 하는 건 batch-delete-image 로 직접 지웠어요.
- 운영 배포에는 `prod`, `latest` 같은 움직이는 태그 대신 **이미지 다이제스트(sha256:...)** 나 버전 태그를 쓰면, 어떤 이미지가 돌고 있는지 헷갈리지 않아요.
