#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-example.typ}"
OUTPUT_FILE="${INPUT_FILE%.typ}.pdf"

COMMIT_ID=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

typst compile \
  --font-path fonts/ \
  --input "commit_id=${COMMIT_ID}" \
  "$INPUT_FILE" "$OUTPUT_FILE"

echo "Compiled ${INPUT_FILE} -> ${OUTPUT_FILE} (commit: ${COMMIT_ID:0:8})"
