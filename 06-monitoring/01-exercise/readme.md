# Ejercicios

## 1. Ejecuta Prometheus en local usando Docker

- Crea una configuración mínima que realice un 'scraping' del propio Prometheus
- Mapea el puerto del cliente web por defecto, y realiza las siguientes queries:
    1. Una cualquiera sobre memoria utilizada
    2. Una cualquiera sobre cpu utilizada

## 2. Explica que son los `exporters`, `recording rules` y `alert rules` en el contexto de Prometheus

## 3. Explica el contenido de la carpeta [01-start-up-loki](./01-start-up-loki/)

## 4. Expl

## 5. Desafíos

### 5.1 Crea un docker compose para realizar un setup con Prometheus 

- Debe incluir como servicio del docker compose la siguiente [App](https://github.com/JaimeSalas/non-political-map/tree/main/app_map)
- Instala la librería [cliente de Python]() para extraer métricas por defecto
- Genera usn servicio Prometheus que como 'target' tenga la app anterior
- Verifica que el 'target' es alcanzado por Prometheus

### 5.2 Desafío Jaeger 

El siguiente [tutoríal](https://medium.com/opentracing/take-opentracing-for-a-hotrod-ride-f6e3141f7941) muestra cómo usar Jaeger, 
sigue los pasos para solucionar los distintos issues y crea notas con tu experiencia.