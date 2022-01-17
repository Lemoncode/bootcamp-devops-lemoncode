const Chance = require('chance');

const chance = new Chance();

module.exports.getRandom = (start, end) => Math.floor((Math.random() * end) + start);

module.exports.delay = (delaySeconds) => new Promise((resolve) => {
  setTimeout(() => {
    resolve();
  }, delaySeconds * 1_000);
});


module.exports.getQuote = () => chance.sentence();