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
    const { jobs, failed, processed } = randomBatchProcess();
    console.log(active, failed, processed);
  }, 5_000);

  return intervalId;
};