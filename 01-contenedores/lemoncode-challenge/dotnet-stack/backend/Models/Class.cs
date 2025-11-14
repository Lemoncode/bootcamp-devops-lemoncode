using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace backend.Models;

public class Class
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }

    [BsonElement("name")]
    public string Name { get; set; } = null!;

    [BsonElement("instructor")]
    public string Instructor { get; set; } = null!;

    [BsonElement("startDate")]
    public DateTime StartDate { get; set; }

    [BsonElement("endDate")]
    public DateTime EndDate { get; set; }

    [BsonElement("duration")]
    public int Duration { get; set; } // En horas

    [BsonElement("level")]
    public string Level { get; set; } = null!; // Beginner, Intermediate, Advanced
}
