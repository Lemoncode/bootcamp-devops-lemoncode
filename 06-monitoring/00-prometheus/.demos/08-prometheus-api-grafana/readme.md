# Prometheus API and Grafana

# Querying Summaries and Histograms

## Setup

```bash
vagrant up
```

After our environemnt gets up, we will have:
  
* `linux-batch`
  * Two docker instances running the batch process exposing on ports 8080 and 8081
  * Linux node exporter
* `linux-web`
  * Two docker instances running the web server process exposing on ports 8080 and 8081
  * Linux node exporter 

Now we can run `Prometheus` as follows:

```bash
vagrant ssh prometheus
```

```bash
prometheus-2.32.1.linux-amd64/prometheus \
 --config.file="/opt/prometheus/prometheus.yaml"
```

Verify targets at http://10.0.0.10:9090/targets.


## 1. HTTP API

Query an instant vector expression:

```
worker_active_jobs
```

- http://10.0.0.10:9090/api/v1/query?query=worker_jobs_active

Query a range vector expression:

```
worker_jobs_total[5m]
```

- http://10.0.0.10:9090/api/v1/query_range?query=rate(worker_jobs_total[5m])&start=1592382830&end=1592383030&step=60

## 2. Grafana

For this demo we're going to setup everything with Docker instead of using VMs, just for convenience.

First let's create a new Docker network.

```bash
docker network create prometheus-test
```
We're going to setup two containers for batch process:

```bash
docker run -d --rm \
  --name batch \
  --network=prometheus-test \
  -e PORT=8080 \
  -p 8080:8080 \
  jaimesalas/prom-batch
```

```bash
docker run -d --rm \
  --name batch2 \
  --network=prometheus-test \
  -e PORT=8081 \
  -p 8081:8081 \
  jaimesalas/prom-batch
```

And other two containers for web:

```bash
docker run -d --rm \
  --name web \
  --network=prometheus-test \
  -e PORT=8082 \
  -p 8082:8082 \
  jaimesalas/prom-web
```

```bash
docker run -d --rm \
  --name web2 \
  --network=prometheus-test \
  -e PORT=8083 \
  -p 8083:8083 \
  jaimesalas/prom-web
```

With this setup we can start `Prometheus`

```bash
# change directoy to `prometheus-config` parent
docker run -d --rm \
  --name prometheus \
  --network=prometheus-test \
  -p 9090:9090 \
  -v `pwd`/prometheus-config:/etc/prometheus \
  prom/prometheus
```

Verify targets at http://localhost:9090/targets.


At last we're ready to add `Grafana`

```bash
docker run \
  --name grafana \
  --network=prometheus-test \
  -p 3000:3000 \
  grafana/grafana:7.0.3
```

Browse to `localhost:3000`, and login into `Grafana` with `admin/admin`