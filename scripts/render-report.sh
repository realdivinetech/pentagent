#!/usr/bin/env bash
# render-report.sh — render an engagement Pentagent report (Markdown) into a
# styled, standalone HTML and an A4 print-ready PDF, both sharing one CSS.
#
# Usage:
#   scripts/render-report.sh <report.md> [output-base] [--skip-pdf]
#
#   <report.md>     The report to render (path or a file inside ./engagements).
#   [output-base]   Output path *without* extension; defaults to the input
#                   filename. Renders $BASE.html and $BASE.pdf alongside.
#   --skip-pdf      HTML only (still validated + CSS applied).
#
# Requires: pandoc (>= 2.12), weasyprint (for PDF) — both ship on Kali.
# Styling: templates/engagement/report/pentest.css

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STYLE="$ROOT/templates/engagement/report/pentest.css"

die() { printf "render-report: %s\n" "$*" >&2; exit 1; }

for c in pandoc weasyprint; do
  command -v "$c" >/dev/null 2>&1 || die "missing dependency: $c (Kali: sudo apt install pandoc weasyprint)"
done
[ -f "$STYLE" ] || die "stylesheet not found: $STYLE"

if [ -n "${1:-}" ]; then SRC="$1"; else die "usage: scripts/render-report.sh <report.md> [output-base] [--skip-pdf]"; fi
shift || true

OUT_BASE=""
DO_PDF=1
for a in "$@"; do
  case "$a" in
    --skip-pdf) DO_PDF=0 ;;
    *) OUT_BASE="$a" ;;
  esac
done

# Resolve input. Also accept bare filenames living under ./engagements.
if [ -f "$SRC" ]; then
  SRC="$(realpath "$SRC")"
elif [ -d "$ROOT/engagements" ] && [ -f "$ROOT/engagements/$SRC" ]; then
  SRC="$(realpath "$ROOT/engagements/$SRC")"
else
  die "input not found: $SRC (tried cwd and ./engagements)"
fi
case "$SRC" in
  *.md) ;;
  *) die "input must be a .md file: $SRC" ;;
esac

if [ -n "$OUT_BASE" ]; then
  mkdir -p "$(dirname "$OUT_BASE")"
  OUT_BASE="$(realpath -m "$OUT_BASE")"
else
  OUT_BASE="${SRC%.md}"
fi

# ---- build metadata from the report's own YAML front matter --------------
# pandoc reads title/subtitle/author/date/abstract automatically; only inject
# fallbacks when the file did not supply them.
META=()
if ! grep -q '^title:' "$SRC"; then
  META+=( -M title="Penetration Test Report" -M author="Pentagent (report-writer)" -M date="$(date +%F)" )
fi

COMMON=( --standalone --embed-resources --toc --toc-depth=3 \
         --css "$STYLE" -f markdown+smart -t html5 )

echo "render-report: $SRC"
pandoc "${COMMON[@]}" "${META[@]}" "$SRC" -o "$OUT_BASE.html"
echo "  OK html -> $(wc -c < "$OUT_BASE.html") bytes ($OUT_BASE.html)"

if [ "$DO_PDF" = 1 ]; then
  pandoc "${COMMON[@]}" "${META[@]}" --pdf-engine=weasyprint "$SRC" -o "$OUT_BASE.pdf"
  PAGES="$(pdfinfo "$OUT_BASE.pdf" 2>/dev/null | awk '/^Pages/{print $2}')"
  echo "  OK pdf -> $OUT_BASE.pdf (${PAGES:-?} pages)"
fi

echo "render-report: done."
