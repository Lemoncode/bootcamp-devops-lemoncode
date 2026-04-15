# AGENTS.md — static/

Guía para agentes de IA que trabajen en la capa frontend de Vacation Swipe.

## Qué hay aquí

Todo el frontend es una SPA estática servida directamente por FastAPI. No hay framework, no hay bundler, no hay npm.

```
index.html                       # Shell HTML; monta <vacation-game>
styles.css                       # Estilos globales del body/header
components/
  destination-card.js            # Web Component <destination-card>
  vacation-game.js               # Web Component <vacation-game> (orquesta todo el juego)
screenshots/                     # Capturas de pantalla del proyecto (no tocar)
```

## Cómo se cargan los scripts

```html
<script src="components/destination-card.js"></script>
<script src="components/vacation-game.js"></script>
```

Sin `type="module"`, sin imports entre archivos. Ambos componentes se registran en `customElements` al cargarse. El orden importa: `destination-card` debe cargarse antes que `vacation-game` porque este último lo instancia en su `render()`.

## Web Components

### `<destination-card>`

- Recibe datos vía la propiedad JS `.data = { ... }` (no atributos HTML).
- Usa Shadow DOM (`mode: "open"`).
- Renderiza: emoji, nombre, tagline, badges de `climate` y `vibe`, y `fun_fact`.
- No tiene estado propio ni lógica de interacción; es puramente presentacional.

### `<vacation-game>`

- Usa Shadow DOM (`mode: "open"`).
- Obtiene los destinos de `GET /api/destinations` al conectarse al DOM.
- Estado interno:
  - `this.destinations` — array completo de destinos
  - `this.currentIndex` — índice de la tarjeta activa
  - `this.liked` — destinos con swipe derecha (✈️)
  - `this._animating` — bloquea interacción durante animaciones
- Flujo principal: `fetchDestinations()` → `render()` → `bindEvents()`.
- `render()` es destructivo: reemplaza todo `shadowRoot.innerHTML` en cada llamada y luego llama a `bindEvents()`.
- Al terminar todas las tarjetas muestra la pantalla de resultado con un destino aleatorio de `this.liked` (o mensaje de "te quedas en casa" si no hay ninguno).

### Lógica de swipe

- **Threshold**: 80 px horizontales para confirmar el swipe.
- Soporta puntero táctil y ratón (eventos `pointerdown/pointermove/pointerup`).
- Durante el arrastre: rotación `dx * 0.08 deg` y opacidad reducida.
- Hints visuales "PASO" / "¡ME VOY!" aparecen con opacidad progresiva al superar 30 px.
- `handleSwipe(like: boolean)` ejecuta la animación de salida y llama a `render()` al terminar.

## Estilos

- `styles.css` solo afecta al `body` y `<header>`. No toca los componentes.
- Todos los estilos de los componentes están encapsulados dentro del Shadow DOM como bloques `<style>` en el `innerHTML`.
- El fondo global es un gradiente: `135deg, #0c4a6e → #0e7490 → #f43f5e88`.

## Convenciones

- **Sin imports ni exports**: los archivos JS son scripts clásicos, no módulos ES. No usar `import`/`export`.
- **Sin dependencias externas**: nada de CDN, nada de librerías. Solo JS nativo.
- **Estilos en shadow DOM**: no añadir clases CSS en `styles.css` para los componentes; van dentro del `innerHTML` de cada componente.
- **`render()` es la única fuente de verdad visual**: no manipular el DOM del shadow root fuera de `render()` salvo para animaciones en curso.
- **`screenshots/`**: directorio de solo lectura. No modificar ni añadir archivos ahí salvo capturas nuevas del proyecto.
