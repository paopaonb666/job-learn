#!/usr/bin/env bash
# 每日复习日志：创建 / 编辑 / 提交 / 推送，一条龙
# 用法： ./scripts/daily.sh
#        ./scripts/daily.sh "docs: 补完 Redis 持久化"
#        ./scripts/daily.sh --no-push

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

TODAY=$(date +%Y-%m-%d)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DIR="$REPO_ROOT/daily/$YEAR/$MONTH"
FILE="$DIR/$TODAY.md"

WEEKDAY=$(date +%u)
case $WEEKDAY in
  1) WD="周一";; 2) WD="周二";; 3) WD="周三";;
  4) WD="周四";; 5) WD="周五";; 6) WD="周六";; 7) WD="周日";;
esac

mkdir -p "$DIR"

if [ ! -f "$FILE" ]; then
  cat > "$FILE" <<EOF
# $TODAY $WD

## 今天做了什么

-

## 学到了什么

-

## 明天计划

- [ ]

EOF
  echo "已新建 $FILE"
fi

if [ -n "$EDITOR" ]; then
  "$EDITOR" "$FILE"
elif command -v code >/dev/null 2>&1; then
  code --wait "$FILE"
elif command -v vim >/dev/null 2>&1; then
  vim "$FILE"
else
  echo "没找到编辑器，请手动编辑：$FILE"
  read -r -p "写完后按回车继续..."
fi

cd "$REPO_ROOT"
git add -A

if git diff --cached --quiet; then
  echo "没有改动，跳过提交。"
  exit 0
fi

MSG="$1"
if [ -z "$MSG" ] || [ "$MSG" = "--no-push" ]; then
  MSG="docs: $TODAY 复习日志"
fi

git commit -m "$MSG"

if [ "$1" = "--no-push" ] || [ "$2" = "--no-push" ]; then
  echo "已提交，按参数跳过推送。"
  exit 0
fi

git push origin HEAD
echo "完成：$MSG"
