const promClient = require('prom-client');

const counter = new promClient.Counter({
  name: 'http_requests_received_total',
  help: 'Total number of requests received and response code',
  labelNames: ['method', 'response_code']
});


const histogram = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Shows processing requests durations',
  labelNames: ['code']
});

const delaySummary = new promClient.Summary({
  name: 'web_delay_seconds',
  help: 'Custom delay added',
});

module.exports.counter = counter;
module.exports.histogram = histogram;
module.exports.delaySummary = delaySummary;