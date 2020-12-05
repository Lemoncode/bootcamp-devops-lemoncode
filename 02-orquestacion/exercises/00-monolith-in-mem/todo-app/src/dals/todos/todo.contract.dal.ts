import { TodoEntity } from './todo.entity';

export interface TodoDAL {
    getTodos(): Promise<TodoEntity[]>;
    getTodoById(id: number): Promise<TodoEntity>;
    createTodo(todo: TodoEntity): Promise<void>;
    updateTodo(id: number, todo: TodoEntity): Promise<void>;
    resolveTodos(): Promise<void>;
    deleteTodoById(id: number): Promise<void>;
}

export type TodoDALFactory = (...args: any[]) => TodoDAL;