namespace backend.Models
{

    public interface ITopicstoreDatabaseSettings
    {
        string TopicsCollectionName { get; set; }
        string ConnectionString { get; set; }
        string DatabaseName { get; set; }
    }

    public class TopicstoreDatabaseSettings : ITopicstoreDatabaseSettings
    {
        public string TopicsCollectionName { get; set; }
        public string ConnectionString { get; set; }
        public string DatabaseName { get; set; }
    }
}
