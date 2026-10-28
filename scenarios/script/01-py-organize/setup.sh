#!/usr/bin/env bash
source /opt/cmdlab/lib/helpers.sh
set -e
mkdir -p "$H/tools"
cat > "$H/tools/organize.py" <<'PY'
#!/usr/bin/env python3
"""폴더 안의 파일을 종류별 폴더로 정리한다.

사용법: python3 organize.py <정리할 폴더> <결과 폴더> [--dry-run]
"""
import shutil
import sys
from pathlib import Path

CATEGORIES = {
    "images": [".jpg", ".jpeg", ".png", ".gif", ".heic"],
    "documents": [".pdf", ".docx", ".xlsx", ".pptx", ".txt", ".hwp"],
    "videos": [".mp4", ".mov"],
}


def category_of(path):
    for name, exts in CATEGORIES.items():
        if path.suffix in exts:
            return name
    return "others"


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    src, dst = Path(sys.argv[1]), Path(sys.argv[2])
    dry_run = "--dry-run" in sys.argv

    moved = 0
    for f in sorted(src.iterdir()):
        if not f.is_file():
            continue
        target = dst / category_of(f) / f.name
        print(f"{f} -> {target}")
        if not dry_run:
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(f, target)
        moved += 1

    print(f"{'(dry-run) ' if dry_run else ''}{moved}개 파일 처리")


if __name__ == "__main__":
    main()
PY
I="$H/inbox"; rm -rf "$I" "$H/sorted"; mkdir -p "$I/phone" "$I/camera" "$I/work/old"
: > /opt/cmdlab/secret/files
mk() { # 경로 종류
  head -c $(rand_int 200 3000) /dev/urandom > "$I/$1"
  printf '%s\t%s\n' "$(md5sum < "$I/$1" | cut -d' ' -f1)" "$2" >> /opt/cmdlab/secret/files
}
dup=$(rand_int 2001 2099)
mk "phone/IMG_$dup.jpg" images; mk "camera/IMG_$dup.jpg" images; mk "IMG_$dup.jpg" images
mk "phone/IMG_$((dup + 1)).JPG" images; mk "camera/DSC_0$(rand_int 100 999).JPG" images
mk "phone/screenshot.png" images; mk "phone/video_$(rand_int 10 99).MOV" videos; mk "camera/clip.mp4" videos
mk "회의록.docx" documents; mk "work/견적서.PDF" documents; mk "work/old/견적서.pdf" documents; mk "work/매출.xlsx" documents
mk "readme.txt" documents; mk "setup.exe" others; mk "work/archive.zip" others; mk "notes" others
for i in $(seq 1 $(rand_int 2 5)); do mk "phone/IMG_$((dup + 1 + i)).jpg" images; done
give "$H/tools" "$I"
