# Running Prometheus

Descargar, ejecutar y explorar Prometheus

## Setup

```Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.network "private_network", ip: "10.0.0.10"
end
```

```bash
vagrant up
```

```bash
vagrant ssh
```

## 1.1 Descargar el servidor Prometheus

```
wget https://github.com/prometheus/prometheus/releases/download/v2.32.1/prometheus-2.32.1.linux-amd64.tar.gz

tar xvfz prometheus-2.32.1.linux-amd64.tar.gz
```

Vamos a echar un ojo a la configuración por defecto [prometheus.yml](prometheus-2.32.1.linux-amd64/prometheus.yml)

```yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
```

```diff
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
- evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
- # scrape_timeout is set to the global default (10s).
-
-# Alertmanager configuration
-alerting:
- alertmanagers:
-   - static_configs:
-       - targets:
-         # - alertmanager:9093
-
-# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
-rule_files:
- # - "first_rules.yml"
- # - "second_rules.yml"
-
-# A scrape configuration containing exactly one endpoint to scrape:
-# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
```

- Hemos eliminado las alertas y las reglas 
- Nos quedamos con global y scrape config

Ahora se debería ver algo como esto:

```yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  

scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
```

## 1.2 Ejecutamos Prometheus con la configuración por defecto

Cambiamos al directorio de descarga y ejecutamos el binario:

```bash
cd prometheus-2.32.1.linux-amd64
./prometheus
```

Si nos fijamos en el `output` deberáimos ver algo como esto:

- Starting TSDB
- Loading configuration file filename=prometheus.yml
- Server is ready to receive web requests

Y un nuevo directorio `data`.

Vamos a abrir un nuevo terminal contra la VM

```bash
vagrant ssh
```

Podemos comprobar que el nuevo directorio `data` se ha creado:

```
vagrant@vagrant:~$ ls prometheus-2.32.1.linux-amd64/data/
chunks_head  lock  queries.active  wal
```

## 1.3 Explorando la UI de Prometheus

Podemos ver las propias métrcas de `Prometheus` en http://localhost:9090/metrics

Desde la terminal ejecutamos:

```bash
curl http://localhost:9090/metrics
```

Desde el `host` podemos navegar a la UI DE Prometheus http://10.0.0.10:9090


Vamos a comprobar las páginas de _Status_

- Configuration
- Command-Line Flags
- Targets
- Service Discovery

Por último vamos añadir algunos datos en la página _Graph_: 

- `go_info`, standard Go info with instance and job labels
- `promhttp_metric_handler_requests_total`, graph (UI shows number of time series)