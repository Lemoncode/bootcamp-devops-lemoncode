#!/usr/bin/env bash
# record.sh — Graba la pantalla con ffmpeg (macOS AVFoundation)
#
# Uso: bash record.sh [segundos] [x] [y] [ancho] [alto]
#
# Argumentos (todos opcionales):
#   segundos  Duración de la grabación (default: 10)
#   x         Desplazamiento horizontal del área de captura (default: 0)
#   y         Desplazamiento vertical del área de captura (default: 0)
#   ancho     Ancho del área de captura en píxeles (default: 1280)
#   alto      Alto del área de captura en píxeles (default: 720)
#
# Ejemplo captura centrada de 800x600 durante 15s:
#   bash record.sh 15 240 90 800 600

set -euo pipefail

DURATION="${1:-10}"
OFFSET_X="${2:-0}"
OFFSET_Y="${3:-0}"
WIDTH="${4:-1280}"
HEIGHT="${5:-720}"

# Detect the first AVFoundation screen device ("Capture screen ...") to avoid using a webcam index.
SCREEN_INDEX="$(ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | sed -n 's/.*\[\([0-9]\+\)\] Capture screen.*/\1/p' | head -1)"

if [[ -z "${SCREEN_INDEX}" ]]; then
  echo "No se encontró un dispositivo de pantalla AVFoundation."
  echo "Verifica permisos de grabación de pantalla para Terminal y prueba:"
  echo "  ffmpeg -f avfoundation -list_devices true -i \"\""
  exit 1
fi

OUTPUT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/workspace/screenshots"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/recording.mov"

echo "=> Grabando ${DURATION}s — área ${WIDTH}x${HEIGHT} en (${OFFSET_X},${OFFSET_Y})"
echo "=> Dispositivo de pantalla detectado: índice ${SCREEN_INDEX}"
echo "=> Salida: $OUTPUT_FILE"
echo "   (Presiona Ctrl+C para detener antes de tiempo)"

ffmpeg -y \
  -f avfoundation \
  -capture_cursor 1 \
  -capture_mouse_clicks 1 \
  -framerate 30 \
  -video_size "${WIDTH}x${HEIGHT}" \
  -i "${SCREEN_INDEX}:none" \
  -vf "crop=${WIDTH}:${HEIGHT}:${OFFSET_X}:${OFFSET_Y}" \
  -t "$DURATION" \
  -c:v libx264 \
  -preset ultrafast \
  -pix_fmt yuv420p \
  "$OUTPUT_FILE"

echo ""
echo "✓ Grabación guardada en: $OUTPUT_FILE"
echo "  Siguiente paso: bash .agents/skills/webapp-to-gif/scripts/convert.sh"
