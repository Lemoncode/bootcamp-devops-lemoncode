using backend.Models;
using MongoDB.Driver;

namespace backend.Service;

public class TopicService(ITopicstoreDatabaseSettings settings)
{
    private readonly IMongoCollection<Topic> _topics = new MongoClient(settings.ConnectionString)
        .GetDatabase(settings.DatabaseName)
        .GetCollection<Topic>(settings.TopicsCollectionName);

    public List<Topic> Get() => _topics.Find(_ => true).ToList();

    public Topic? Get(string id) => _topics.Find(topic => topic.Id == id).FirstOrDefault();

    public Topic Create(Topic topic)
    {
        _topics.InsertOne(topic);
        return topic;
    }

    public void Update(string id, Topic topicIn) =>
        _topics.ReplaceOne(topic => topic.Id == id, topicIn);

    public void Remove(string id) =>
        _topics.DeleteOne(topic => topic.Id == id);
}