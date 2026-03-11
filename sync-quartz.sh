#!/bin/bash
# sync-quartz: podo-analysis (Obsidian vault) → quartz/content 동기화
# Usage: ./sync-quartz.sh 또는 sync-quartz (alias 설정 시)

set -e

VAULT="/Users/d1/Desktop/podo-analysis"
QUARTZ="/Users/d1/Desktop/quartz/content"

if [ ! -d "$QUARTZ" ]; then
  echo "Error: quartz/content 디렉토리가 없습니다: $QUARTZ"
  exit 1
fi

echo "=== podo-analysis → quartz 동기화 시작 ==="

# 폴더 매핑 (넘버링 제거)
FOLDERS=(
  "1. 대시보드 분석|대시보드 분석"
  "2. 리텐션 분석|리텐션 분석"
  "3. 튜터 비용 분석|튜터 비용 분석"
  "4. 유저 플로우 분석|유저 플로우 분석"
  "5. VOC 분석|VOC 분석"
  "6. UIUX 개선|UIUX 개선"
  "7. 스쿼드 로드맵|스쿼드 로드맵"
  "8. Feature Development|Feature Development"
)

updated=0
added=0
deleted=0

# 각 폴더 동기화
for pair in "${FOLDERS[@]}"; do
  src_folder="${pair%%|*}"
  dst_folder="${pair##*|}"

  src_path="$VAULT/$src_folder"
  dst_path="$QUARTZ/$dst_folder"

  if [ ! -d "$src_path" ]; then
    continue
  fi

  mkdir -p "$dst_path"

  # 소스 → 대상 복사 (신규 + 변경)
  for f in "$src_path"/*.md; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    dst="$dst_path/$base"

    if [ ! -f "$dst" ]; then
      cp "$f" "$dst"
      echo "  + $dst_folder/$base"
      added=$((added + 1))
    elif ! diff -q "$f" "$dst" > /dev/null 2>&1; then
      cp "$f" "$dst"
      echo "  ~ $dst_folder/$base"
      updated=$((updated + 1))
    fi
  done

  # 대상에만 있는 파일 삭제 (소스에서 제거된 파일)
  for f in "$dst_path"/*.md; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    if [ ! -f "$src_path/$base" ]; then
      rm "$f"
      echo "  - $dst_folder/$base"
      deleted=$((deleted + 1))
    fi
  done
done

# frontmatter 체크 및 자동 추가
echo ""
echo "=== frontmatter 검증 ==="
fm_fixed=0
find "$QUARTZ" -name "*.md" -not -name "index.md" -print0 | while IFS= read -r -d '' f; do
  first_nonblank=$(awk 'NF{print; exit}' "$f")
  if [ "$first_nonblank" != "---" ]; then
    # 파일명에서 title 추출
    title=$(basename "$f" .md)
    tmp=$(mktemp)
    printf -- '---\ntitle: %s\n---\n' "$title" > "$tmp"
    sed '/./,$!d' "$f" >> "$tmp"
    mv "$tmp" "$f"
    echo "  + frontmatter: $(basename "$f")"
  fi
done

echo ""
echo "=== 결과: +${added} 추가, ~${updated} 수정, -${deleted} 삭제 ==="

# Git 커밋 & 푸시
cd "$QUARTZ/.."
if [ -n "$(git status --porcelain content/)" ]; then
  git add content/
  git commit -m "podo-analysis 동기화 ($(date '+%Y-%m-%d %H:%M'))"
  echo ""
  read -p "push할까요? (y/n) " answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    git push
    echo "=== 배포 완료! ==="
  else
    echo "커밋만 완료. 나중에 git push 하세요."
  fi
else
  echo "=== 변경사항 없음 ==="
fi
