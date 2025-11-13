using backend.Models;
using backend.Service;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ClassesController(ClassService classService) : ControllerBase
{
    // GET: api/classes
    [HttpGet]
    public IEnumerable<Class> Get() => classService.Get();

    // GET api/classes/{id}
    [HttpGet("{id:length(24)}", Name = "GetClass")]
    public ActionResult<Class> Get(string id)
    {
        var @class = classService.Get(id);

        if (@class == null)
        {
            return NotFound();
        }

        return @class;
    }

    // POST api/classes
    [HttpPost]
    public ActionResult<Class> Create(Class @class)
    {
        classService.Create(@class);
        return CreatedAtRoute("GetClass", new { id = @class.Id }, @class);
    }

    // PUT api/classes/{id}
    [HttpPut("{id:length(24)}")]
    public IActionResult Update(string id, Class classIn)
    {
        var @class = classService.Get(id);

        if (@class == null)
        {
            return NotFound();
        }

        classService.Update(id, classIn);

        return NoContent();
    }

    // DELETE api/classes/{id}
    [HttpDelete("{id:length(24)}")]
    public IActionResult Delete(string id)
    {
        var @class = classService.Get(id);

        if (@class == null)
        {
            return NotFound();
        }

        classService.Remove(id);

        return NoContent();
    }
}
