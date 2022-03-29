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

## Pre-requisites

Generate some load to the web app instances.

```bash
./loadgen.sh
```

## 1. Summary 

Calculate the average delay added in slow mode.

- `web_delay_seconds_count`
  - Tells me the number of times that slow mode has been used on each of my instances.
- `web_delay_seconds_sum`
  - The other part of a Summary metric is the total. This give us the total amount of delay that's been added acrosss all responses for each of my instances. Both `web_delay_seconds_count` and `web_delay_seconds_sum` are counters.
- `sum without(job, os, runtime) (rate(web_delay_seconds_count[5m]))` - req/s
  - This is going to show us the rate of change for the count metric, so this is the number of slow mode requests per second that have been received.
- `sum without(job, os, runtime) (rate(web_delay_seconds_sum[5m]))` - delay/s
  - This is going to show us the rate delay per second
- `sum without(job, os, runtime) (rate(web_delay_seconds_sum[5m])) / sum without(job, os, runtime) (rate(web_delay_seconds_count[5m]))` - avg delay


## 2. Histogram

Calculate the 90th percentile response time.

- `http_request_duration_seconds_bucket`
  - This is showing the histogram buckets, 
- `rate(http_request_duration_seconds_bucket[5m])`
  - They are counters so we can use rate to see how they change over time, and this returns the rate of increase per second for each bucket.
- `rate(http_request_duration_seconds_bucket{code="200"}[5m])`
  - We can filter to get just the 200 responses
- `sum without(code, job, method, os, runtime) (rate(http_request_duration_seconds_bucket{code="200"}[5m]))`
  - We can aggregate this to remove some of the labels. Here we're showing the rate of change per second for each bucket in each instance. 
- `histogram_quantile(0.90, sum without(code, job, method, os, runtime) (rate(http_request_duration_seconds_bucket{code="200"}[5m])))`
  - The most useful of Histogram is that I can get `Prometheus` to calculate the percentile for me.