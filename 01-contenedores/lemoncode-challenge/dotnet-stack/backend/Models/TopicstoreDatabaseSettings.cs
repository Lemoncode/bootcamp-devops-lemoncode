namespace backend.Models;

public interface ITopicstoreDatabaseSettings
{
    string TopicsCollectionName { get; set; }
    string ConnectionString { get; set; }
    string DatabaseName { get; set; }
}

public class TopicstoreDatabaseSettings : ITopicstoreDatabaseSettings
{
    public string TopicsCollectionName { get; set; } = null!;
    public string ConnectionString { get; set; } = null!;
    public string DatabaseName { get; set; } = null!;
}
