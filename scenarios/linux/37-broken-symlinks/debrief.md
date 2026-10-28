# 해설

```bash
find ~/site -xtype l | wc -l > ~/answer.txt     # 1. 개수 (숨김 파일 포함)
ln -sfn /srv/uploads ~/site/releases/v3/uploads  # 2. 하나는 고치고
find ~/site -xtype l                             #    남은 목록 확인
find ~/site -xtype l -delete                     # 3. 나머지 삭제
```

## -type l 과 -xtype l
| 조건 | 뜻 |
|---|---|
| `-type l` | 링크 **자체**가 링크인가 → 모든 심볼릭 링크 |
| `-xtype l` | 링크를 **따라간 결과**도 링크인가 → 따라갈 수 없는 깨진 링크 |

다른 방법: `find ~/site -type l ! -exec test -e {} \; -print` (`test -e` 는 링크를 따라가서 대상이 있는지 확인).

## 상대 경로 링크
`config.yml -> ../../shared/config.yml` 처럼 상대 경로 링크는 **링크가 있는 폴더 기준**으로 해석돼요. 그래서 폴더째 옮겨도 함께 옮긴 대상이면 살아 있지만, `/mnt/old-nfs/...` 같은 절대 경로는 서버가 바뀌면 깨지기 쉬워요.

## ln -sfn 의 -n
링크 `uploads` 가 이미 **폴더를 가리키고** 있으면, `ln -sf 새대상 uploads` 는 `uploads` 를 폴더로 보고 그 **안에** 새 링크를 만들어 버려요. `-n` 은 링크 자체를 바꾸게 해 줘요. 배포 롤백에서 `current` 링크를 바꿀 때도 같은 이유로 `-sfn` 을 써요.
