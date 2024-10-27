//models/topics.js

const mongoose = require('mongoose'),
    Schema = mongoose.Schema;

const TopicSchema = new Schema({
    name: String
});

module.exports = mongoose.model('Topic', TopicSchema);