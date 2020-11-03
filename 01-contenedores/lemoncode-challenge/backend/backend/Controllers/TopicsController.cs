using System.Collections.Generic;
using backend.Models;
using backend.Service;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TopicsController : ControllerBase
    {
        private readonly TopicService _topicService;

        public TopicsController(TopicService topicService)
        {
            _topicService = topicService;
        }

        // GET: api/<TopicsController>
        [HttpGet]
        public IEnumerable<Topic> Get() => _topicService.Get();


        // GET api/<TopicsController>/5
        [HttpGet("{id:length(24)}", Name = "GetTopic")]
        public ActionResult<Topic> Get(string id)
        {
            var topic = _topicService.Get(id);

            if (topic == null)
            {
                return NotFound();
            }

            return topic;
        }

        // POST api/<TopicsController>
        [HttpPost]
        public ActionResult<Topic> Create(Topic topic)
        {
            _topicService.Create(topic);

            return topic;
        }

        [HttpPut("{id:length(24)}")]
        public IActionResult Update(string id, Topic topicIn)
        {
            var topic = _topicService.Get(id);

            if (topic == null)
            {
                return NotFound();
            }

            _topicService.Update(id, topicIn);

            return NoContent();
        }

        [HttpDelete("{id:length(24)}")]
        public IActionResult Delete(string id)
        {
            var topic = _topicService.Get(id);

            if (topic == null)
            {
                return NotFound();
            }

            _topicService.Remove(topic.Id);

            return NoContent();
        }
    }
}
