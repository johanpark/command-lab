"""moto 가 실제 AWS 와 다르게 동작해서 학습자를 헷갈리게 하는 곳을 고친다 (이미지 빌드 때 한 번 실행)."""
import importlib.util
import pathlib

# ECR: list-images / describe-images 의 --filter tagStatus=TAGGED|UNTAGGED 를 무시하고 전부 돌려준다
#      → 태그 없는 것만 지우려던 학습자가 운영 이미지까지 지우게 됨
p = pathlib.Path(importlib.util.find_spec('moto.ecr.responses').origin)
s = p.read_text()
FILTER = '''
        _ts = (self._get_param("filter") or {}).get("tagStatus")  # cmdlab
        if _ts == "TAGGED":
            images = [i for i in images if i.image_tags]
        elif _ts == "UNTAGGED":
            images = [i for i in images if not i.image_tags]
'''
targets = [
    '        images = self.ecr_backend.list_images(repository_str, registry_id)\n',
    '        images = self.ecr_backend.describe_images(\n            repository_str, registry_id, image_ids\n        )\n',
]
if '# cmdlab' not in s:
    for t in targets:
        assert t in s, f'moto 코드가 예상과 달라요: {t!r}'
        s = s.replace(t, t + FILTER.lstrip('\n'))
    p.write_text(s)
print('patched', p)
