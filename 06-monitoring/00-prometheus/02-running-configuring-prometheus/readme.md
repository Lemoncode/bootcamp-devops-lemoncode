# Ejecutando y Configurando Prometheus

> El servidor de Prometheus es un único binario, el cual se ejecuta en un único proceso.

## Demo: Ejecutando Prometheus

[Demo: Ejecutando Prometheus](../.demos/03-running-prometheus/readme.md)


## Configurando Targets y Service Discovery

La configuración más básica que podemos utilizar es la estática (la que acabamos de ver), la cual es una lista fija con nombres de dominios o IP's.

Una mejor opción incluso para proyectos pequeños es utilizar `file service discovery`

> Prometheus también soporta `dinamic service discovery` pero depende de la plataforma.

## Demo: Configurando Prometheus

[Demo: Configurando Prometheus](../.demos/04-configuring-prometheus/readme.md)


## Target Labels y Relabelling 

`Prometheus` añade las etiquetas de `job` e `instance`

```
http_request_duration_seconds_count
{
  code="200",
  method="GET",
  job="web",
  instance="linux-web"
}
```

Todas estas etiquetas, tienen el mismo objetivo, ayudar con `aggregation` y `querying` 

`job` e `instance` son las etiquetas funamentales, pero en casi todos los escenarios vamos a querer añadir más o mnaipularlas.

`Prometheus` nos dá tres opciones de configuración para este fin.

1. Añadir tus propias `target labels` en la configuración estática o `file discovery` - No puedes reaccionar al valor de otras etiquetas.
2. **relabelling** que ocurre cuando el `target` está siendo preguntado (`scraped`). En esta fase se puede modificar las `labels` y quitar `targets`
3. Cuando las métricas ya han sido extraidas, en el `metric relabel stage` - Podemos hacer las mimas operacione que el relabelling pero no tienes acceso a las etiquetas que introduce el `service discovery` 

## Demo: Enriqueciendo y Filtrando etiquetas

[Demo: Enriqueciendo y Filtrando etiquetas](../.demos/05-filtering-and-enriching-labels/readme.md)