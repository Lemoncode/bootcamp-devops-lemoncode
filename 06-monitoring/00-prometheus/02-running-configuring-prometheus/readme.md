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
