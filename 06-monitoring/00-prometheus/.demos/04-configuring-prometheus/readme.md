# Configuring Prometheus

## Setup

```bash
vagrant up
```

# 1. Static configuration for scrape targets

Vamos a crear un fichero de configuración para Prometheus en lugar de usar el que viene por defecto:

```yaml
global:
  scrape_interval: 20s  # default 1m 

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']  
  
  - job_name: 'linuxbatch'
    static_configs:
      - targets: ['linux-batch:9100']
      
  - job_name: 'batch'
    static_configs:
      - targets: ['linux-batch:8080']

  - job_name: 'linuxweb'
    scrape_timeout: 15s  # default 10 s
    static_configs:
      - targets: ['linux-web:9100']

  - job_name: 'web'
    metrics_path: /metrics
    scheme: http  # can include TLS and auth for HTTPS
    static_configs:
      - targets: ['linux-web:8080']

```

Abrimos sesión SSH contra la vm de Prometheus 

```bash
vagrant ssh prometheus
```

Podemos comprobar que tenemos conectividad con las otras máquinas:

```bash
ping linux-batch
```

```bash
ping linux-web
```

Ahora vamos a arrancar `prometheus` de forma interactiva para alimentarle nuestra configuración por defecto, primero vamos a crear el fichero:

```bash
nano prometheus-config.yml
```

`Prometheus` viene con una utilidad `promtool` para verificar que el `yaml` es correcto 

```bash
prometheus-2.32.1.linux-amd64/promtool \
 check config prometheus-config.yml 
```

Debemos obtener una salida como la siguiente:

```
Checking prometheus-config.yml
  SUCCESS: 0 rule files found
```

Y ahora podemos arrancar `Prometheus` de la siguiente forma:

```bash
prometheus-2.32.1.linux-amd64/prometheus \
 --config.file="prometheus-config.yml" \
 --web.enable-lifecycle
```

`--web.enable-lifecycle` abilitará un endpoint para recargar la configuración de `Prometheus` sin reiniciar el servidor.

## 2. Exploramos los nuevos target Explore the new targets

Comprobamos http://10.0.0.10:9090/config y http://10.0.0.10:9090/targets


Vamos a comprobar que las métricas son recogidas en la página _Graph_:

- `up`
- `scrape_duration_seconds`
- `scrape_samples_scraped`
- `worker_jobs_active` - labels & graph

> Navegar & refrescar la web app en http://10.0.0.12:8080/quote

Check metrics:

- `http_request_duration_seconds_bucket`


## 3. Hacer una actualización en vivo del config

Podemos comprobar el último load timestamp de la configuración:

- `prometheus_config_last_reload_success_timestamp_seconds`

> Hacemos un cambio en este fichero [config file](./prometheus-config.yml)

```diff
global:
  scrape_interval: 20s # default 1m

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "linuxbatch"
    static_configs:
      - targets: ["linux-batch:9100"]

  - job_name: "batch"
    static_configs:
      - targets: ["linux-batch:8080"]

  - job_name: "linuxweb"
    scrape_timeout: 15s # default 10 s
    static_configs:
      - targets: ["linux-web:9100"]

  - job_name: "web"
    metrics_path: /metrics
    scheme: http # can include TLS and auth for HTTPS
    static_configs:
-     - targets: ["linux-web:8080"]
+     - targets: ["linux-web:8081"]
```

Hemos cambiado el puerto a uno incorrecto.

```bash
curl -X POST http://10.0.0.10:9090/-/reload
```

Si ejecutamos de nuevo `prometheus_config_last_reload_success_timestamp_seconds`

Y echamos un ojo en `targets` veremos que uno de ellos ha desaparecido.
