import { Server } from 'http';
import { app, db as Knex } from './app';
import supertest, { agent } from 'supertest';
import { TodoEntity } from './dals/todos/todo.entity';
import { TodoModel } from './models/todo.model';

let server: Server;
let request: supertest.SuperTest<any>;

beforeEach(async () => {
  server = await app.listen(process.env.PORT);
  request = agent(server);
  await Knex.from('todos').delete();
});

afterEach(() => {
  server.close();
});

afterAll(async () => {
  await Knex.destroy();
});

describe('/api/', () => {
  describe('GET verb', () => {
    it('should return todos', async () => {
      // Arrange
      await Promise.all([
        insertTodo({ id: 1, title: 'Learn node', completed: false }),
        insertTodo({ id: 2, title: 'Learn JS', completed: false }),
        insertTodo({ id: 3, title: 'Learn Docker', completed: false }),
      ]);

      // Act
      const response = await request.get('/api/');
      const todos = response.body;

      // Assert
      expect(todos.length).toBe(3);
    });
  });

  describe('GET verb with id parameter', () => {
    it('should return a single todo', async () => {
      // Arrange
      await insertTodo({ id: 1, title: 'Learn node', completed: false });

      // Act
      const response = await request.get('/api/1/');
      const todo = response.body;

      // Assert
      expect(todo.id).toBe(1);
      expect(todo.title).toBe('Learn node');
    });
  });

  describe('POST verb creates a new todo', () => {
    it('should create a new todo', async () => {
      // Arrange
      const todo: TodoModel = {
        id: 0,
        title: 'New Todo',
        completed: false,
        dueDate: '2020-11-27',
      };

      // Act
      const response = await request.post('/api/').send(todo);

      // Assert
      expect(response.status).toBe(201);
    });
  });

  describe('PATCH verb updates related fields', () => {
    it('should return ok status code', async () => {
      // Arrange
      await insertTodo({ id: 1, title: 'Learn node', completed: false });

      // Act
      const response = await request.patch('/api/1').send({ completed: true });

      // Assert
      expect(response.status).toBe(200);
    });
  });

  describe('PUT verb completes all todos', () => {
    it('should return ok status', async () => {
      // Arrange
      await Promise.all([
        insertTodo({ id: 1, title: 'Learn node', completed: false }),
        insertTodo({ id: 2, title: 'Learn JS', completed: false }),
        insertTodo({ id: 3, title: 'Learn Docker', completed: false }),
      ]);

      // Act 
      const response = await request.put('/api/');

      // Assert
      expect(response.status).toBe(200);
    });
  });

  describe('DELETE verb remove a given todo', () => {
    it('should return ok status code', async () => {
      // Arrange
      await insertTodo({ id: 1, title: 'Learn node', completed: false });

      // Act
      const response = await request.delete('/api/1/');

      // Assert
      expect(response.status).toBe(204);
    });
  });
});

const insertTodo = ({ id, title, completed }: { id: number; title: string; completed: boolean }): Promise<TodoEntity> =>
  Knex('todos')
    .insert({ id, title, completed }, '*')
    .then(([todo]) => todo);
