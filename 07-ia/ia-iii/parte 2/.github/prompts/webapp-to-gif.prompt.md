---
name: "Demo GIF"
description: "Graba la app web en ejecución y genera un GIF optimizado. Usa cuando quieras crear una demo visual para el README, redes sociales o slides."
argument-hint: "ej: 10 segundos, preset readme, guardar como demo-swipe"
agent: agent
---

Quiero crear un GIF de demostración de la aplicación web usando la skill `webapp-to-gif`.

## Contexto del proyecto

- La app se ejecuta en `http://localhost:8000`
- Las capturas se guardan en `workspace/screenshots/`
- Scripts disponibles en `.agents/skills/webapp-to-gif/scripts/`

## Tu tarea

Sigue estos pasos en orden:

1. **Verifica que ffmpeg y gifski estén instalados.** Si falta alguno, indica el comando de instalación con Homebrew y espera confirmación antes de continuar.

2. **Comprueba que la app esté corriendo** haciendo una petición a `http://localhost:8000`. Si no responde, muestra el comando para arrancarla (`python app.py`) y espera confirmación.

3. **Pregunta al usuario** (si no lo especificó en los argumentos):
   - Duración de la grabación en segundos (default: 10)
   - Preset de salida: `readme` (GitHub), `social` (Twitter/redes), `slides` (docs)
   - Nombre del archivo GIF de salida (default: `demo`)

4. **Ejecuta la grabación recomendada con Playwright**:
   ```bash
   bash .agents/skills/webapp-to-gif/scripts/record-playwright.sh http://localhost:8000 [segundos] recording-playwright
   ```
   Si falla Playwright o el usuario pide captura manual, usa fallback:
   ```bash
   bash .agents/skills/webapp-to-gif/scripts/record.sh [segundos]
   ```
   En modo Playwright no hace falta interacción manual; en modo fallback sí.

5. **Convierte a GIF** con el script `convert.sh`:
   ```bash
   bash .agents/skills/webapp-to-gif/scripts/convert.sh workspace/screenshots/recording-playwright.webm [nombre] --preset [preset]
   ```

6. **Muestra un resumen** con:
   - Ruta del GIF generado
   - Tamaño del archivo
   - Snippet de Markdown listo para pegar en el README:
     ```markdown
     ![Demo](workspace/screenshots/[nombre].gif)
     ```
