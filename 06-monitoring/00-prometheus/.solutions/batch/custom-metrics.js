const promClient = require('prom-client');

// Reference: https://github.com/siimon/prom-client/blob/master/example/counter.js
const counter = new promClient.Counter({
  name: 'worker_jobs_total',
  help: 'Total jobs handle',
  labelNames: ['code']
});

// Reference: https://github.com/siimon/prom-client/blob/master/example/gauge.js
const gauge = new promClient.Gauge({
  name: 'worker_jobs_active',
  help: 'Worker jobs in process'
});


module.exports.counter = counter;
module.exports.gauge = gauge;