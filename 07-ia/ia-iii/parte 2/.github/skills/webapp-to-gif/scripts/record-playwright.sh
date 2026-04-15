#!/usr/bin/env bash
# record-playwright.sh — Graba la app web en navegador con Playwright
#
# Uso:
#   bash record-playwright.sh [url] [segundos] [nombre_salida] [delay_ms]
#
# Ejemplo:
#   bash .agents/skills/webapp-to-gif/scripts/record-playwright.sh http://localhost:8000 12 recording 1200

set -euo pipefail

URL="${1:-http://localhost:8000}"
SECONDS="${2:-12}"
OUTPUT_NAME="${3:-recording-playwright}"
DELAY_MS="${4:-1200}"

npx --yes -p playwright node .agents/skills/webapp-to-gif/scripts/record-playwright.cjs "$URL" "$SECONDS" "$OUTPUT_NAME" "$DELAY_MS"
