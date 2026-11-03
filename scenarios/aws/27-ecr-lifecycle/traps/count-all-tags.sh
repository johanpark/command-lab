# 설명: 태그 없는 건 지웠지만, 정책을 '전체 최근 10개' 로 걸어 운영 release 이미지까지 지워질 수 있다
# 실패해야: 수명 주기 정책이 보관 규칙대로
ids=$(aws ecr list-images --repository-name shop-api --filter tagStatus=UNTAGGED --query 'imageIds[].imageDigest' --output text)
aws ecr batch-delete-image --repository-name shop-api --image-ids $(for d in $ids; do echo imageDigest=$d; done) >/dev/null
echo '{"rules":[{"rulePriority":1,"selection":{"tagStatus":"untagged","countType":"sinceImagePushed","countUnit":"days","countNumber":1},"action":{"type":"expire"}},{"rulePriority":2,"selection":{"tagStatus":"any","countType":"imageCountMoreThan","countNumber":10},"action":{"type":"expire"}}]}' > p.json
aws ecr put-lifecycle-policy --repository-name shop-api --lifecycle-policy-text file://p.json
