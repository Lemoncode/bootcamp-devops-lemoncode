import bodyParser from 'body-parser';
import 'dotenv/config';
import express from 'express';
import { todoDALFactory } from './dals/todos/todo.dal';
import { mapTodoEntity, mapTodoEntityCollection, mapTodoModel } from './models/todo.model';

export const app = express();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// ------ Static files for frontend
app.use(express.static('public'));

let todoDAL;

const retrieveTodoDAL = () => {
  if (!todoDAL) {
    return todoDALFactory();
  }
  return todoDAL;
};

app.get('/live/', (_, res) => res.send(true));

app.get('/api/', async (_, res) => {
  todoDAL = retrieveTodoDAL();
  const todoEntities = await todoDAL.getTodos();
  res.send(mapTodoEntityCollection(todoEntities));
});

app.get('/api/:id/', async (req, res) => {
  const { id } = req.params;
  todoDAL = retrieveTodoDAL();
  const todoEntity = await todoDAL.getTodoById(+id);
  res.send(mapTodoEntity(todoEntity));
});

app.post('/api/', async (req, res) => {
  try {
    todoDAL = retrieveTodoDAL();
    await todoDAL.createTodo(mapTodoModel(req.body));
    res.status(201);
    res.send('ok');
  } catch (error) {
    console.error(error);
    res.status(500);
    res.send('error');
  }
});

app.patch('/api/:id/', async (req, res) => {
  try {
    const { id } = req.params;
    todoDAL = retrieveTodoDAL();
    await todoDAL.updateTodo(+id, mapTodoModel(req.body));
    res.status(200);
    res.send('ok');
  } catch (error) {
    console.error(error);
    res.status(500);
    res.send('error');
  }
});

app.put('/api/', async (_, res) => {
  try {
    todoDAL = retrieveTodoDAL();
    await todoDAL.resolveTodos();
    res.status(200);
    res.send('ok');
  } catch (error) {
    console.error(error);
    res.status(500);
    res.send('error');
  }
});

app.delete('/api/:id/', async (req, res) => {
  try {
    const { id } = req.params;
    todoDAL = retrieveTodoDAL();
    await todoDAL.deleteTodoById(+id);
    res.status(204);
    res.send('ok');
  } catch (error) {
    console.error(error);
    res.status(500);
    res.send('error');
  }
});

const PORT = process.env.PORT || 3000;

if (process.env.NODE_ENV !== 'test') {
  console.log('execute');
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}
