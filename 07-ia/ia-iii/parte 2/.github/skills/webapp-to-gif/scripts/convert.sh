#!/usr/bin/env bash
# convert.sh — Convierte un video a GIF de alta calidad con gifski
#
# Uso: bash convert.sh [archivo_entrada] [nombre_salida] [--preset readme|social|slides]
#
# Argumentos (todos opcionales):
#   archivo_entrada  Ruta al video fuente (default: recording-playwright.webm si existe; si no, recording.mov)
#   nombre_salida    Nombre del GIF de salida sin extensión (default: demo)
#   --preset         Aplica configuración predefinida por destino:
#                      readme   — 15 FPS, 600px ancho (GitHub README)
#                      social   — 24 FPS, 480px ancho (Twitter/redes)
#                      slides   — 10 FPS, 800px ancho (docs/presentaciones)
#
# Ejemplo con preset para README:
#   bash convert.sh workspace/screenshots/recording-playwright.webm mi-demo --preset readme

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCREENSHOTS_DIR="$ROOT_DIR/workspace/screenshots"

DEFAULT_INPUT="$SCREENSHOTS_DIR/recording-playwright.webm"
if [[ ! -f "$DEFAULT_INPUT" ]]; then
  DEFAULT_INPUT="$SCREENSHOTS_DIR/recording.mov"
fi

INPUT="${1:-$DEFAULT_INPUT}"
OUTPUT_NAME="${2:-demo}"
PRESET="${3:-}"

# Defaults
FPS=15
WIDTH=600

# Aplicar preset si se especifica
case "$PRESET" in
  --preset)
    case "${4:-}" in
      social)  FPS=24; WIDTH=480 ;;
      slides)  FPS=10; WIDTH=800 ;;
      readme) FPS=15; WIDTH=600 ;;
      *)
        echo "Preset no válido: ${4:-<vacío>}"
        echo "Usa uno de: readme | social | slides"
        exit 1
        ;;
    esac
    ;;
  "")
    ;;
  *)
    echo "Argumentos inválidos."
    echo "Uso: bash convert.sh [archivo_entrada] [nombre_salida] [--preset readme|social|slides]"
    exit 1
    ;;
esac

FRAMES_DIR="$SCREENSHOTS_DIR/frames_tmp"
OUTPUT_GIF="$SCREENSHOTS_DIR/${OUTPUT_NAME}.gif"

mkdir -p "$FRAMES_DIR"

echo "=> Extrayendo frames de: $INPUT"
echo "   FPS: $FPS | Ancho: ${WIDTH}px"

# Extraer frames como PNG con ffmpeg (escalando al ancho objetivo)
ffmpeg -y -i "$INPUT" \
  -vf "fps=${FPS},scale=${WIDTH}:-1:flags=lanczos" \
  "$FRAMES_DIR/frame%04d.png"

FRAME_COUNT=$(ls "$FRAMES_DIR"/frame*.png 2>/dev/null | wc -l | tr -d ' ')
echo "   Frames extraídos: $FRAME_COUNT"

echo "=> Generando GIF con gifski..."

gifski \
  --fps "$FPS" \
  --width "$WIDTH" \
  --quality 90 \
  --output "$OUTPUT_GIF" \
  "$FRAMES_DIR"/frame*.png

# Limpiar frames temporales
rm -rf "$FRAMES_DIR"

GIF_SIZE=$(du -sh "$OUTPUT_GIF" | awk '{print $1}')
echo ""
echo "✓ GIF generado: $OUTPUT_GIF (${GIF_SIZE})"
echo "  Previsualizar: open \"$OUTPUT_GIF\""
