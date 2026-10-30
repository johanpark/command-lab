태그 없는 이미지 다이제스트만: `aws ecr list-images --repository-name shop-api --filter tagStatus=UNTAGGED --query 'imageIds[].imageDigest' --output text`
지우기는 `--image-ids imageDigest=sha256:aaa imageDigest=sha256:bbb ...` 처럼 여러 개를 한 번에:
`aws ecr batch-delete-image --repository-name shop-api --image-ids $(for d in <위 결과>; do echo imageDigest=$d; done)`
---
규칙은 **세 개**. 각각:
- 태그 없음: `"tagStatus": "untagged"`, `sinceImagePushed` 1일
- dev: `"tagStatus": "tagged", "tagPrefixList": ["dev-"]`, `sinceImagePushed` 14일
- release: `"tagStatus": "tagged", "tagPrefixList": ["release-"]`, `"countType": "imageCountMoreThan", "countNumber": 10` (countUnit 없음)
---
**`"tagStatus": "any"` 로 "최근 N개만" 을 걸면 prod 이미지까지 대상이 돼요.** 접두사로 대상을 좁히세요.
`vim policy.json` 으로 쓰고 `jq . policy.json` 으로 문법 확인 →
`aws ecr put-lifecycle-policy --repository-name shop-api --lifecycle-policy-text file://policy.json`
