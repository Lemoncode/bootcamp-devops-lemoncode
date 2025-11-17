namespace backend.Models;

public interface IClassDatabaseSettings
{
    string ClassesCollectionName { get; set; }
    string ConnectionString { get; set; }
    string DatabaseName { get; set; }
}

public class ClassDatabaseSettings : IClassDatabaseSettings
{
    public string ClassesCollectionName { get; set; } = null!;
    public string ConnectionString { get; set; } = null!;
    public string DatabaseName { get; set; } = null!;
}

