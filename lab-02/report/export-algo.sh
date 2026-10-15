#!/usr/bin/env bash
# Экспорт схем алгоритмов из algo.drawio в PDF, разложенных по папкам.
#
# Страница drawio с именем «<алгоритм>-<номер листа>» выгружается в
#   image/algo/<алгоритм>/<номер листа>.pdf
# Страница без номера в конце имени («standard») — в
#   image/algo/<имя>/1.pdf
#
# Использование: ./export-algo.sh [путь к .drawio] [папка для PDF]
# Путь к draw.io можно переопределить переменной окружения DRAWIO.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${1:-$SCRIPT_DIR/algo.drawio}"
OUT_DIR="${2:-$SCRIPT_DIR/image/algo}"

if [[ -z "${DRAWIO:-}" ]]; then
    if command -v drawio >/dev/null 2>&1; then
        DRAWIO="$(command -v drawio)"
    else
        DRAWIO="/Applications/draw.io.app/Contents/MacOS/draw.io"
    fi
fi

[[ -f "$SRC" ]] || { echo "Нет файла схем: $SRC" >&2; exit 1; }
[[ -x "$DRAWIO" ]] || { echo "Не найден draw.io: $DRAWIO (задайте DRAWIO=...)" >&2; exit 1; }

# Имена страниц в порядке следования (номер страницы для draw.io начинается с 1)
PAGES=()
while IFS= read -r name; do
    PAGES+=("$name")
done < <(xmllint --xpath '//diagram/@name' "$SRC" | sed -E 's/^ *name="(.*)"$/\1/')

[[ ${#PAGES[@]} -gt 0 ]] || { echo "В $SRC не найдено ни одной страницы" >&2; exit 1; }

# Старые PDF удаляются, чтобы не оставались листы удалённых или переименованных страниц
rm -rf "${OUT_DIR:?}"
mkdir -p "$OUT_DIR"

index=1
for page in "${PAGES[@]}"; do
    if [[ "$page" =~ ^(.+)-([0-9]+)$ ]]; then
        algo="${BASH_REMATCH[1]}"
        sheet="${BASH_REMATCH[2]}"
    else
        algo="$page"
        sheet=1
    fi

    out="$OUT_DIR/$algo/$sheet.pdf"
    if [[ -e "$out" ]]; then
        echo "Ошибка: страница «$page» совпадает по пути с другой страницей ($out)" >&2
        exit 1
    fi
    mkdir -p "$OUT_DIR/$algo"

    "$DRAWIO" --export --format pdf --crop --page-index "$index" --output "$out" "$SRC" >/dev/null 2>&1 \
        || { echo "Ошибка экспорта страницы «$page»" >&2; exit 1; }
    echo "$page -> ${out#"$SCRIPT_DIR"/}"
    index=$((index + 1))
done

echo "Готово: ${#PAGES[@]} стр. в ${OUT_DIR#"$SCRIPT_DIR"/}"
