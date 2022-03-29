# Filtering and Enriching Labels

## Setup

```bash
vagrant up
```

Customizing metric labels in config

## 1. Add target labels

Create `prometheus-config-1.yml`

```yml
#prometheus-config-1.yml
global:
  scrape_interval: 15s 

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "linuxbatch"
    static_configs:
      - targets: ["linux-batch:9100"]
        labels:
          os: linux
          runtime: vm

  - job_name: "batch"
    static_configs:
      - targets: ["linux-batch:8080"]
        labels:
          os: linux
          runtime: container

  - job_name: "linuxweb"
    scrape_timeout: 15s # default 10 s
    static_configs:
      - targets: ["linux-web:9100"]
        labels:
          os: linux
          runtime: vm

  - job_name: "web"
    metrics_path: /metrics
    scheme: http # can include TLS and auth for HTTPS
    static_configs:
      - targets: ["linux-web:8080"]
        labels:
          os: linux
          runtime: docker
```

Get into the prometheus vm

```bash
vagrant ssh prometheus
```

If there's a running instance of `Prometheus` stop it. Run with new config, first create the file:

```bash
nano prometheus-config-1.yml
```

And now run it:

```bash
prometheus-2.32.1.linux-amd64/prometheus \
 --config.file="prometheus-config-1.yml"
```
Check http://10.0.0.10:9090/service-discovery

Graph:

- `worker_jobs_active`

> Now includes `os` and `runtime` labels

## 2. Using relabel config for consolidation

Browse to the web app at http://10.0.0.12:8080/quote?slow=true

Graph:

- `worker_jobs_active`
- `web_delay_seconds_count`

> Mismatched label values for `runtime`

Let's create a new config that uses file service discovery and adds relabel config, create `prometheus-config-2.yml`

```yml
# prometheus-config-2.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "web"
    file_sd_configs:
      - files:
          - "web.json"

  - job_name: "batch"
    file_sd_configs:
      - files:
          - "batch.json"
    relabel_configs:
      - source_labels: [runtime]
        regex: container
        target_label: runtime
        replacement: docker

```

Create `web.json`

```json
[
  {
    "targets": [
      "linux-web:9100"
    ],
    "labels": {
      "os": "linux",
      "runtime": "vm"
    }
  },
  {
    "targets": [
      "linux-web:8080"
    ],
    "labels": {
      "os": "linux",
      "runtime": "docker"
    }
  }
]
```

Create `batch.json`

```json
[
  {
    "targets": [
      "linux-batch:9100"
    ],
    "labels": {
      "os": "linux",
      "runtime": "vm"
    }
  },
  {
    "targets": [
      "linux-batch:8080"
    ],
    "labels": {
      "os": "linux",
      "runtime": "container"
    }
  }
]
```

Stop `Prometheus` and copy the new files

```bash
nano web.json
```

```bash
nano batch.json
```

```bash
nano prometheus-config-2.yml
```

Run `Prometheus` with the new setup

```bash
prometheus-2.32.1.linux-amd64/prometheus \
 --config.file="prometheus-config-2.yml"
```

Check the target config at http://10.0.0.10:9090/service-discovery & http://10.0.0.10:9090/targets

And the new data in the _Graph_ page:

- `worker_jobs_active`
- `web_delay_seconds_count`

> Consistent label values for `runtime`

## 3. Manipulating metrics & labels in config

Check in the _Graph_ page:

- `go_goroutines` - all Go apps record this
- `node_filesystem_avail_bytes` - includes a mountpoint label
- `node_filesystem_free_bytes` - includes a fstype label

Let's create a new config, create `prometheus-config-3.yml`

```yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "web"
    file_sd_configs:
      - files:
          - "web.json"
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: "go_.*"
        action: drop
      - source_labels: [__name__, fstype]
        regex: "node_filesystem_free_bytes;(.*)"
        replacement: "${1}"
        target_label: device

  - job_name: "batch"
    file_sd_configs:
      - files:
          - "batch.json"
    relabel_configs:
      - source_labels: [runtime]
        regex: container
        target_label: runtime
        replacement: docker
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: "go_.*"
        action: drop
      - source_labels: [__name__, mountpoint]
        regex: "node_filesystem_avail_bytes;.*"
        action: replace
        replacement: ""
        target_label: mountpoint

```

- drops Go metrics from servers
- removes the `mountpoint` label from the node available bytes metric
- copies the `fstype` label for filesystem free bytes to `device`

Stop `Prometheus` and copy the new files

```bash
nano prometheus-config-3.yml
```

Run `Prometheus`

```bash
prometheus-2.32.1.linux-amd64/prometheus \
 --config.file="prometheus-config-3.yml"
```

Check results on http://10.0.0.10:9090