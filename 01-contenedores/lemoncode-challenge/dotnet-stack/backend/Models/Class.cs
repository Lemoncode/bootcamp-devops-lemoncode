using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace backend.Models;

public class Class
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }

    [BsonElement("Name")]
    public string Name { get; set; } = null!;

    [BsonElement("Instructor")]
    public string Instructor { get; set; } = null!;

    [BsonElement("StartDate")]
    public DateTime StartDate { get; set; }

    [BsonElement("EndDate")]
    public DateTime EndDate { get; set; }

    [BsonElement("Duration")]
    public int Duration { get; set; } // En horas

    [BsonElement("Level")]
    public string Level { get; set; } = null!; // Beginner, Intermediate, Advanced
}
