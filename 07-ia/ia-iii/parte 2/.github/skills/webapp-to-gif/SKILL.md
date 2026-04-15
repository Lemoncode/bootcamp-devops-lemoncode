---
name: webapp-to-gif
description: "Record a running web application and convert the recording to an optimized GIF. Use when: grabar pantalla de una web app, capturar demo de aplicación web, crear GIF para README, crear GIF para redes sociales, convertir video a GIF, screen recording to GIF, demo GIF, webapp recording, ffmpeg screen capture, gifski convert."
argument-hint: "URL de la app y descripción de la demo (ej: http://localhost:8000, demo del swipe)"
---

# Webapp to GIF

Graba una demo de la aplicación web en el navegador con **Playwright** (recomendado) y convierte el resultado a GIF con **ffmpeg + gifski**.

## Cuándo usar esta skill

- Crear GIFs para el README del repo en GitHub
- Generar demos para documentación o slides
- Producir clips para redes sociales / Twitter
- Cualquier flujo: grabar web app → GIF optimizado

## Prerequisitos

Ambas herramientas son **obligatorias** para esta skill:

- `ffmpeg` para la grabación y extracción de frames
- `gifski` para generar el GIF final con buena calidad

Verifica que estén instaladas antes de continuar:

```bash
# Verificar ffmpeg
ffmpeg -version | head -1

# Verificar gifski
gifski --version
```

Si falta alguna:

1. **Solicita permiso explícito al usuario** antes de instalar.
2. Instala con Homebrew:

```bash
brew install ffmpeg
brew install gifski
```

No continúes con el flujo de grabación/conversión hasta que ambas dependencias estén disponibles.

También necesitas Node.js para ejecutar el script de Playwright por `npx`.

```bash
node -v
npx -v
```

## Procedimiento completo

### Paso 1 — Asegúrate de que la app esté corriendo

```bash
# Ejemplo con la app de este proyecto
python app.py
```

Anota la URL exacta (ej: `http://localhost:8000`).

### Paso 2 — Grabar demo de la app (Playwright, recomendado)

Usa el script [./scripts/record-playwright.sh](./scripts/record-playwright.sh):

```bash
# Uso recomendado
bash .agents/skills/webapp-to-gif/scripts/record-playwright.sh http://localhost:8000 12 recording-playwright

# Movimiento más natural (más lento entre acciones)
bash .agents/skills/webapp-to-gif/scripts/record-playwright.sh http://localhost:8000 12 recording-playwright 1200
```

Este flujo graba la pestaña del navegador y evita capturar webcam.
El script genera un archivo `.webm` en `workspace/screenshots/`.

### Paso 3 — Alternativa manual: captura de pantalla con ffmpeg

Usa el script [./scripts/record.sh](./scripts/record.sh):

```bash
# Uso básico (graba 10 segundos en la pantalla principal)
bash .agents/skills/webapp-to-gif/scripts/record.sh

# Personalizar duración y área de captura
bash .agents/skills/webapp-to-gif/scripts/record.sh [segundos] [x] [y] [ancho] [alto]
```

El script genera un archivo `recording.mov` en `workspace/screenshots/`.
El script detecta automáticamente un dispositivo `Capture screen` de AVFoundation para evitar capturar la webcam por error.

Para conocer las dimensiones de pantalla disponibles:
```bash
ffmpeg -f avfoundation -list_devices true -i ""
```

### Paso 4 — Convertir a GIF con gifski

Usa el script [./scripts/convert.sh](./scripts/convert.sh):

```bash
# Uso básico (prioriza recording-playwright.webm si existe)
bash .agents/skills/webapp-to-gif/scripts/convert.sh

# Personalizar el archivo de entrada y nombre de salida
bash .agents/skills/webapp-to-gif/scripts/convert.sh [archivo_entrada] [nombre_salida]
```

El GIF resultante se guarda en `workspace/screenshots/`.

### Paso 5 — Verificar el resultado

```bash
# Ver tamaño del archivo resultante
ls -lh workspace/screenshots/*.gif

# Abrir para previsualizar
open workspace/screenshots/*.gif
```

## Presets por destino

| Destino | FPS | Ancho | Notas |
|---------|-----|-------|-------|
| README GitHub | 15 | 600px | Equilibrio calidad/tamaño |
| Redes sociales | 24 | 480px | Mayor fluidez |
| Slides / docs | 10 | 800px | Prioriza claridad visual |

Para aplicar un preset, pasa los parámetros al script de conversión (ver `convert.sh --help`).

## Resolución de problemas

| Error | Causa probable | Solución |
|-------|---------------|----------|
| `AVFoundation input device not found` | Índice de pantalla incorrecto | Listar con `ffmpeg -f avfoundation -list_devices true -i ""` |
| `No se pudo cargar playwright` | Playwright no disponible en ejecución | Ejecutar con `npx --yes -p playwright node .agents/skills/webapp-to-gif/scripts/record-playwright.cjs` |
| `gifski: command not found` | No instalado | `brew install gifski` |
| GIF muy pesado (>5 MB) | FPS o colores altos | Bajar `--fps` a 10, reducir `--width` |
| GIF cortado | Duración insuficiente | Aumentar el argumento `segundos` en record.sh |
| Pantalla en negro | Permisos de grabación denegados | Ir a Preferencias → Privacidad → Grabación de pantalla → autorizar Terminal |
| Se grabó la webcam en vez de la app | Índice AVFoundation apuntando a cámara | Usar `record.sh` actualizado (autodetecta `Capture screen`) y validar dispositivos con `ffmpeg -f avfoundation -list_devices true -i ""` |
