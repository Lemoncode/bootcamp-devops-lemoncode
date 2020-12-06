import { TodoDALFactory } from './todo.contract.dal';
import { TodoEntity } from './todo.entity';

let todos: TodoEntity[] = [];

export const todoDALFactory: TodoDALFactory = () => ({
  getTodos() {
    return new Promise<TodoEntity[]>((resolve) => {
      setTimeout(() => {
        resolve(todos);
      }, 200);
    });
  },
  getTodoById(id: number) {
    return new Promise<TodoEntity>((resolve) => {
      setTimeout(() => {
        const todo = todos.find((t) => t.id === id);
        resolve(todo);
      }, 200);
    });
  },
  async createTodo(todo: TodoEntity) {
    return new Promise((resolve) => {
      setTimeout(() => {
        todo.id = Date.now();
        todos = todos.concat([todo]);
        resolve();
      }, 200);
    });
  },
  async updateTodo(id: number, todo: TodoEntity) {
    return new Promise((resolve) => {
      setTimeout(() => {
        todos = todos.map((t) => {
          if (t.id === id) {
            return { ...t, completed: todo.completed };
          }
          return t;
        });
        resolve();
      }, 200);
    });
  },
  async resolveTodos() {},
  async deleteTodoById(id: number) {
    return new Promise((resolve) => {
      setTimeout(() => {
        todos = todos.filter((t) => t.id !== id);
        resolve();
      });
    });
  },
});
