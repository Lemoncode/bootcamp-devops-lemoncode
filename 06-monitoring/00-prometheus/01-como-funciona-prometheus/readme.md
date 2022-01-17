# Comprendiendo cómo funciona Prometheus

## Explorando la Arquitectura de Prometheus

Las cosas pueden salir mal en muchos niveles. Para reaccionar ante ese tipo de situaciones, necesita una solución de monitoreo y alerta que rastree métricas y vea tendencias antes de que suceda algo realmente malo.

Y eso es lo que Prometheus precisamente nos da, una herramienta de monitorización `open-source`.

> Mostrar diagrama

* `Prometheus` es una aplicación para ejecutar en un servidor.
* `Scheduler` recoge métricas.
* Las métricas se almacenan en una `time series database` que se ejecuta en el mismo servidor.
* Expone una `API` 
* Expone una `Web UI`
* Sistema de alertas.

## ¿Qué hace a prometheus diferente?

La forma en que toma `Prometheus` las métricas de los distintos sistemas sólo precisa de un `exporter`.

El `exporter` provee todas la mátricas en un `endpoint`. `Prometheus` coge esas métricas de los distintos endpoints.

`Prometheus` no se preocupa del `exporter`, sólo de recuperar las métricas en un formato estandar.

Los componentes que monitoriza `Prometheus` pueden ser distintos entre si, y las cosas que queremos monitorizar serán distintas. `Prometheus` provee una capa de consistencia para la monitorización.

> El proceso de exportar y recolectar métricas es el mismo para todos ellos.

### Ejemplos

```
# HELP node_filefd_allocated File descriptor statistics: allocated.
# TYPE node_filefd_allocated gauge
node_filefd_allocated 1184
```

```
# HELP node_disk_io_time_seconds_total Total seconds spent foing I/Os.
# TYPE node_disk_io_time_seconds_total counter
node_disk_io_time_seconds_total{device="sda"} 104.296 
```

```
# HELP process_cpu_seconds_total Total user and system CPU time.
# TYPE process_cpu_seconds_total counter
process_cpu_seconds_total 5.23
```

## Client Libraries

* Java
* GO
* Nodejs
* Python
* Elixir
* .NET
* ....

## Tipos de Métricas

### Counter

Un `Counter` es un tipo de métrica que siempre aumenta. 

```
http_requests_total 1000000
cpu_seconds_total 3000
                        @ 22:00
```

```
http_requests_total 970000
cpu_seconds_total 3000
                        @ 21:00
```

```
http_requests_total - http_requests_total offset 1h = 30000
```

### Gauge

El `Gauge` es un tipo de métrica que toma un `snapshot` the un valor cambiante.

```
http_requests_active 2000
memory_allocated_bytes 4.832e+09
```

```
http_requests_active 900
memory_allocated_bytes 3.642e+09
```

```
memory_allocated_bytes / (1024*1024*1024) = 4.5 # gigabytes
```

### Summary

El `Summary` es un tipo de métrica que sirve para tomar el tamaño medio de algo.

Es una métrica que presenta dos tipos de información:

* `count` - el número de veces que ha ocurrido el evento 
* `sum` - la suma de todos los eventos

```
calculation_seconds_count 3
calculation_seconds_sum 15
                        @ 21:00
```

```
calculation_seconds_count 10
calculation_seconds_sum 113
                        @ 21:01
```


### Histogram

El `Histogram` guarda los datos en `buckets`, el valor devuelto es la cuenta de eventos por cada `bucket`

```
calculation_seconds_bucket{le="1"}  0
calculation_seconds_bucket{le="5"}  3
calculation_seconds_bucket{le="10"}  6
calculation_seconds_bucket{le="20"}  9
calculation_seconds_bucket{le="60"}  10
```

Se incluye el total de eventos en el bucket con label `+Inf`

## Demo: Counters & Gauges

[Demo: Counters & Gauges](../02-counters-gauges/readme.md)

## Demo: Summaries & Histograms

[Demo: Summaries & Histograms](../03-summaries-histograms/readme.md)

## Etiquetas y Granularidad
