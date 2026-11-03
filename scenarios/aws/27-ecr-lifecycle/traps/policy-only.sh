# 설명: 정책만 걸고 지금 쌓인 태그 없는 이미지는 그대로 두고, release 이미지에 기간 만료를 건다
# 실패해야: 태그 없는 이미지를 지금 모두
# 실패해야: 수명 주기 정책이 보관 규칙대로
echo '{"rules":[{"rulePriority":1,"selection":{"tagStatus":"untagged","countType":"sinceImagePushed","countUnit":"days","countNumber":1},"action":{"type":"expire"}},{"rulePriority":2,"selection":{"tagStatus":"tagged","tagPrefixList":["dev-"],"countType":"sinceImagePushed","countUnit":"days","countNumber":14},"action":{"type":"expire"}},{"rulePriority":3,"selection":{"tagStatus":"tagged","tagPrefixList":["release-"],"countType":"sinceImagePushed","countUnit":"days","countNumber":30},"action":{"type":"expire"}}]}' > p.json
aws ecr put-lifecycle-policy --repository-name shop-api --lifecycle-policy-text file://p.json
