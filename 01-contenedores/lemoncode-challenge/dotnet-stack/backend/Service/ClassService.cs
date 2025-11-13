using backend.Models;
using MongoDB.Driver;

namespace backend.Service;

public class ClassService(IClassDatabaseSettings settings)
{
    private readonly IMongoCollection<Class> _classes = new MongoClient(settings.ConnectionString)
        .GetDatabase(settings.DatabaseName)
        .GetCollection<Class>(settings.ClassesCollectionName);

    public List<Class> Get() => _classes.Find(_ => true).ToList();

    public Class? Get(string id) => _classes.Find(@class => @class.Id == id).FirstOrDefault();

    public Class Create(Class @class)
    {
        _classes.InsertOne(@class);
        return @class;
    }

    public void Update(string id, Class classIn) =>
        _classes.ReplaceOne(@class => @class.Id == id, classIn);

    public void Remove(string id) =>
        _classes.DeleteOne(@class => @class.Id == id);
}