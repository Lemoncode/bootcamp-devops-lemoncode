using backend.Models;
using backend.Service;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/[controller]")]
[ApiController]
public class TopicsController(TopicService topicService) : ControllerBase
{
    // GET: api/topics
    [HttpGet]
    public IEnumerable<Topic> Get() => topicService.Get();

    // GET api/topics/{id}
    [HttpGet("{id:length(24)}", Name = "GetTopic")]
    public ActionResult<Topic> Get(string id)
    {
        var topic = topicService.Get(id);

        if (topic == null)
        {
            return NotFound();
        }

        return topic;
    }

    // POST api/topics
    [HttpPost]
    public ActionResult<Topic> Create(Topic topic)
    {
        topicService.Create(topic);
        return CreatedAtRoute("GetTopic", new { id = topic.Id }, topic);
    }

    // PUT api/topics/{id}
    [HttpPut("{id:length(24)}")]
    public IActionResult Update(string id, Topic topicIn)
    {
        var topic = topicService.Get(id);

        if (topic == null)
        {
            return NotFound();
        }

        topicService.Update(id, topicIn);

        return NoContent();
    }

    // DELETE api/topics/{id}
    [HttpDelete("{id:length(24)}")]
    public IActionResult Delete(string id)
    {
        var topic = topicService.Get(id);

        if (topic == null)
        {
            return NotFound();
        }

        topicService.Remove(id);

        return NoContent();
    }
}
