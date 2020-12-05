import { TodoEntity } from '../dals/todos/todo.entity';

export interface TodoModel {
  id: number;
  title: string;
  completed: boolean;
  dueDate: string;
}

export const mapTodoEntity = (todo: TodoEntity): TodoModel => {
  const t = {
    ...todo,
    dueDate: todo.due_date,
  };
  const { due_date, ...todoModel } = t;
  return todoModel;
};

export const mapTodoEntityCollection = (todos: TodoEntity[]): TodoModel[] => todos.map(mapTodoEntity);

export const mapTodoModel = (todo: TodoModel): TodoEntity => {
  const t = {
    ...todo,
    due_date: todo.dueDate,
  };
  const { dueDate, ...todoEntity } = t;
  return todoEntity;
};

export const mapTodoModelCollection = (todos: TodoModel[]): TodoEntity[] => todos.map(mapTodoModel);
