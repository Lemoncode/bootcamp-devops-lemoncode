# Querying Gauges and Counters

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


## 1. Gauge

- `worker_jobs_active`
  - The current active jobs gauge in batch processes.
- `worker_jobs_active{instance="linux-batch:8080"}` - selector
  - If we want to see just the data of one instance we can use a selector
- `sum (worker_jobs_active)`  - aggregation operator
  - If we want to see data of all instances
- `sum without(instance) (worker_jobs_active)` 
  - If we want to exclude one label but include all the others
- `sum without(instance, job, os, runtime) (worker_jobs_active)`
  - If we exclude all the labels is the same as doing it over the entire metric 
- `avg without(instance, job, os, runtime) (worker_jobs_active)`
  - We can change the aggregation function to get the avarage
- `max without(instance, job, os, runtime) (worker_jobs_active)`
  - Or even we can get the maximum value
- `sum without(job, os, runtime) (worker_jobs_active)` - Graph
  - Here we can see how this value is changing over time

All these expressions use a gauge metric, which is just a snapshot at a point in time, and they are really easy to work with because you can aggregate the raw values. 

## 2. Counter

Evalaute expressions over the processor's total jobs metric.

- `worker_jobs_total` - one much bigger, started earlier
  - Between two conatiners, we're producing for time series here (including OS)
- `worker_jobs_total[5m]` - range vector
  - We can add a range `[5m]` to see the values over time. For each time series, we get all the samples in the last 5 minutes. This is the total value since the metric began.
- `rate(worker_jobs_total[5m])` - rates very similar
  - With counter we are more interested on change over time. This gives te rate of change of the counter over a 5 minute window, and is telling the increase per second. using the the rate function with a counter gives us gauge in the output, and we can aggregate that over time.
- `sum without(instance, job, os, runtime) (rate(worker_jobs_total[5m]))`
  - This gives us the rate of change for each status.
- `sum without(status, instance, job, os, runtime) (rate(worker_jobs_total[5m]))`
  - This gives us the rate of change of all jobs.
- `sum without(instance, job, os, runtime) (rate(worker_jobs_total{status="failed"}[5m]))`
  - We can apply this to get just the failed jobs.
- `sum without(job, os, runtime) (rate(worker_jobs_total{status="failed"}[5m]))` - Graph
- `sum without(job, os, runtime) (rate(worker_jobs_total{status="processed"}[5m]))` - Graph