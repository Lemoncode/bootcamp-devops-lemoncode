# PromQL

## ¿Por qué necesiatamos PromQL?

```ini
worker_jobs_total{instance="i1", status="processed"} 150
```

Lo podemos modelar igual en SQL:


| instance | job_status | job_count |
| -------- | ---------- | --------- |
| i1       | processed  | 150       |


Si queremos el total de registros podemos hacer:

```sql
SELECT
SUM(job_count) FROM
job_summaries
```

```promql
sum
without(instance, status)
(worker_jobs_total)
```

Recordemos que `Prometheus` usa un `TSDB`, si queremos modelar eso con SQL:

| instance | job_status | job_count | timestamp  |
| -------- | ---------- | --------- | ---------- |
| i1       | processed  | 150       | 1592210327 |
| i1       | processed  | 158       | 1592210357 |
| i1       | processed  | 210       | 1592210387 |

> Muchísmo peso en SQL

`Prometheus` almacena este tipo de data de una manera mucho más eficiente:

```
150 @ 1592210327
158 @ 1592210357
210 @ 1592210387
```

> Cada muestra en una serie de tiempo suele pesar 2 bytes

> Tenemos un tipo de datos especifico y un lenguaje que se alinea con el.

## PromQL Syntax

### Expression

```ini
# query
worker_jobs_active
```

```ini
# response
worker_jobs_active { instance="i1", job="batch" } 84
worker_jobs_active { instance="i2", job="batch" } 51
```

### Filtering Expression

```ini
# query
worker_jobs_active {instance="i1"}
```

```ini
# response
worker_jobs_active { instance="i1", job="batch" } 84
```

### Range Results

```ini
# query
worker_jobs_active[3m]
```

```ini
# response
worker_jobs_active { instance="i1", job="batch" }
70 @15929292929.892
19 @17929292765.892
34 @18929292765.851
worker_jobs_active { instance="i2", job="batch" }
95 @15929292929.892
56 @17929292765.892
55 @18929292765.851
```

Los podemos combinar con selectores

```ini
# query
worker_jobs_active { instance="i1" }[3m]
```

```ini
# response
worker_jobs_active { instance="i1", job="batch" }
70 @15929292929.892
19 @17929292765.892
34 @18929292765.851
```

### Operators

```ini
# query
sum(worker_jobs_active)
```

```ini
# response
135
```

```ini
# query
sum without(job)
(worker_jobs_active)
```

```ini
# response
worker_jobs_active {instance="i1"} 80
worker_jobs_active {instance="i2"} 55
```

## Demo: Querying Gauges & Counters

[Demo: Querying Gauges & Counters](../.demos/06-querying-gauges-counters/readme.md)


## Demo: Querying Summaries and Histograms

[Demo: Querying Summaries and Histograms](../.demos/07-querying-summaries-histograms/readme.md)


## Demo: Prometheus API and Grafana

[Demo: Prometheus API and Grafana](../.demos/08-prometheus-api-grafana/readme.md)