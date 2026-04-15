---
name: "Revisar accesibilidad app"
description: "Audita la accesibilidad de Vacation Swipe. Use when: revisar accesibilidad, auditoria a11y, WCAG, teclado, foco, contraste, lector de pantalla, Web Components."
argument-hint: "Qué revisar: app completa, pantalla, flujo o componente"
agent: "agent"
---
Revisa la accesibilidad de Vacation Swipe usando como alcance prioritario el argumento que acompaña a este prompt. Si no se indica nada, revisa la app completa.

Por defecto, combina revisión de código y revisión en navegador cuando ambas sean posibles, y entrega una auditoría completa antes que un resumen superficial.

Contexto del proyecto:
- Frontend con HTML, CSS y Web Components nativos
- Punto de entrada principal: [static/index.html](../../static/index.html)
- Estilos globales: [static/styles.css](../../static/styles.css)
- Componente principal del juego: [static/components/vacation-game.js](../../static/components/vacation-game.js)

Objetivo:
- Detectar problemas reales de accesibilidad con foco en impacto para personas usuarias
- Priorizar hallazgos concretos frente a recomendaciones genéricas
- Usar WCAG 2.2 AA como referencia por defecto

Cómo revisar:
1. Lee solo los archivos relevantes para el alcance pedido.
2. Si puedes inspeccionar la app en ejecución o en navegador, combina revisión visual y de comportamiento con revisión de código.
3. Si no puedes ejecutar o inspeccionar la UI, haz una auditoría estática y deja esa limitación explícita.
4. Presta especial atención a HTML semántico, navegación por teclado, orden de foco, visibilidad del foco, nombres accesibles, contraste, tamaños de objetivo táctil, texto dinámico, estados interactivos y compatibilidad con lector de pantalla.
5. En Web Components, revisa también riesgos de accesibilidad dentro de Shadow DOM, roles, etiquetas, botones sin nombre y contenido dinámico no anunciado.

Qué comprobar como mínimo:
- Estructura semántica de la página: `html[lang]`, `title`, headings y landmarks
- Botones, enlaces y controles con nombre accesible claro
- Navegación completa sin ratón
- Estados `hover`, `focus` y `active` visibles y consistentes
- Contraste suficiente en texto, iconos y controles principales
- Mensajes o cambios dinámicos que puedan requerir anuncios accesibles
- Textos de ayuda o instrucciones que dependan solo de gestos
- Responsive sin pérdida de acceso a contenido o controles

Formato de salida:

## Resumen
- Alcance revisado
- Método usado: código, navegador o ambos
- Riesgo general: alto, medio o bajo
- Cobertura alcanzada y limitaciones principales

## Hallazgos
Enumera solo problemas reales o muy probables. Para cada hallazgo incluye:
1. Severidad: alta, media o baja
2. Problema
3. Impacto en la persona usuaria
4. Evidencia concreta con referencias a archivos o comportamiento observado
5. Recomendación de solución

## Vacíos de validación
Indica qué no pudiste confirmar sin ejecutar pruebas manuales, lector de pantalla o contraste automatizado.

## Quick wins
Propón entre 3 y 5 mejoras pequeñas y de alto impacto si existen.

Si no detectas problemas claros, dilo explícitamente y menciona los riesgos residuales o pruebas que faltaría hacer.

No modifiques código salvo que se pida explícitamente.