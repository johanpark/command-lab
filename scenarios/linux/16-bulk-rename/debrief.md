# 해설

```bash
cd ~/photos
for f in *.JPG; do echo mv "$f" "2026-trip_${f%.JPG}.jpg"; done   # 미리보기
for f in *.JPG; do mv "$f" "2026-trip_${f%.JPG}.jpg"; done        # 실행
ls
```

## 함정 포인트: 따옴표
```bash
for f in *.JPG; do mv $f 2026-trip_${f%.JPG}.jpg; done   # ❌
```
따옴표가 없으면 `IMG_0100 (1).JPG` 가 `IMG_0100` 과 `(1).JPG` 두 단어로 쪼개져서 `mv` 가 엉뚱하게 동작합니다. **변수는 항상 `"$변수"`** 가 셸의 철칙이에요.

## 변수 자르기 정리
| 문법 | `f=photo.tar.gz` 일 때 |
|---|---|
| `${f%.gz}` | `photo.tar` (뒤에서 짧게 자르기) |
| `${f%%.*}` | `photo` (뒤에서 길게 자르기) |
| `${f#*.}` | `tar.gz` (앞에서 짧게 자르기) |
| `${f/photo/pic}` | `pic.tar.gz` (바꾸기) |
| `${#f}` | `12` (길이) |

## 다른 방법
```bash
rename 's/^(.*)\.JPG$/2026-trip_$1.jpg/' *.JPG   # rename 도구가 있으면 한 줄로
```
