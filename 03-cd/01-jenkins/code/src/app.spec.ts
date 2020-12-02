import { Server } from 'http';
import { app } from './app';
import supertest, { agent } from 'supertest';
import { TodoModel } from './models/todo.model';

import { todoDALFactory } from './dals/todos/todo.dal';
jest.mock('./dals/todos/todo.dal');

const todos = [
  { id: 1, title: 'Learn node, please!!', completed: false },
  { id: 2, title: 'Learn JS', completed: false },
  { id: 3, title: 'Learn Docker', completed: false },
]; 

(todoDALFactory as jest.Mock).mockImplementation(() => ({
  getTodos() {
    return todos; 
  },
  getTodoById(id: number) {
    return todos.find((t) => t.id === id);
  },
  createTodo(todo) {
    return { id: Date.now(), ...todo };
  },
}));

let server: Server;
let request: supertest.SuperTest<any>;

describe('/api/', () => {
  describe('GET verb', () => {
    it('should return todos', async (done) => {
      // Arrange
      server = await app.listen(process.env.PORT);
      request = agent(server);

      // Act
      const response = await request.get('/api/');
      const todos = response.body;

      // Assert
      expect(todos.length).toBe(3);
      removeServer(done);
    });
  });

  describe('GET verb with id parameter', () => {
    it('should returna single todo', async (done) => {
      // Arrange
      server = await app.listen(process.env.PORT);
      request = agent(server);

      // Act
      const response = await request.get('/api/1/');
      const todo = response.body;

      // Assert
      expect(todo.id).toBe(1);
      expect(todo.title).toBe('Learn node, please!!');
      removeServer(done);
    });
  });

  describe('POST verb creates a new todo', () => {
    it('should create a new todo', async (done) => {
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
      removeServer(done);
    });
  });
});

const removeServer = (done) => {
  server.close();

  server.on('close', () => {
    done();
  });
};
