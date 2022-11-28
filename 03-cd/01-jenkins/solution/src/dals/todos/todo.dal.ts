import Knex from 'knex';
import { TodoDALFactory } from './todo.contract.dal';
import { TodoEntity } from './todo.entity';

export const todoDALFactory: TodoDALFactory = (knex: Knex) => ({
  getTodos() {
    return knex<TodoEntity>('todos').then((r) => r);
  },
  getTodoById(id: number) {
    return knex<TodoEntity>('todos').where('id', id).first();
  },
  async createTodo(todo: TodoEntity) {
    return await knex<TodoEntity>('todos').insert(todo);
  },
  async updateTodo(id: number, todo: TodoEntity) {
    return await knex<TodoEntity>('todos')
      .where('id', id)
      .update({ ...todo });
  },
  async resolveTodos() {
    return await knex<TodoEntity>('todos').update({
      completed: true,
    });
  },
  async deleteTodoById(id: number) {
    return await knex<TodoEntity>('todos').where('id', id).del();
  },
});
