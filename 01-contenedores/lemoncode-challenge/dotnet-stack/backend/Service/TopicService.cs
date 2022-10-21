using backend.Models;
using MongoDB.Driver;
using System;
using System.Collections.Generic;

namespace backend.Service
{
    public class TopicService
    {
        private readonly IMongoCollection<Topic> _topics;

        public TopicService(ITopicstoreDatabaseSettings settings)
        {
            var client = new MongoClient(settings.ConnectionString);
            var database = client.GetDatabase(settings.DatabaseName);

            _topics = database.GetCollection<Topic>(settings.TopicsCollectionName);
        }

        public List<Topic> Get() => _topics.Find(topic => true).ToList();
        public Topic Get(string id) => _topics.Find<Topic>(topic => topic.Id == id).FirstOrDefault();
        public Topic Create(Topic topic)
        {
            _topics.InsertOne(topic);
            return topic;
        }
        public void Update(string id, Topic topicIn) =>
            _topics.ReplaceOne(topic => topic.Id == id, topicIn);

        public void Remove(Topic topicIn) => _topics.DeleteOne(topic => topic.Id == topicIn.Id);

        public void Remove(string id) => _topics.DeleteOne(topic => topic.Id == id);

    }
}