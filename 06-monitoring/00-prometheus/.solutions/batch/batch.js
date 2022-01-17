const { counter, gauge } = require('./custom-metrics');

const getRandom = (start, end) => Math.floor((Math.random() * end) + start);

const randomBatchProcess = () => {
  const jobs = getRandom(50, 500);
  const failed = getRandom(1, 50);
  const processed = jobs - failed;
  const active = getRandom(1, 100);
  return { active, failed, processed };
};

module.exports.batch = () => {
  const intervalId = setInterval(() => {
    const { active, failed, processed } = randomBatchProcess();

    counter.labels('200').inc(processed);
    counter.labels('500').inc(failed);

    gauge.set(active);
  }, 5_000);

  return intervalId;
};