import React, { useEffect, useState } from 'react';

import { useExecuteAsync } from '../hooks/use-execute-async';
import { useExecuteFireForget } from '../hooks/use-execute-fire-forget';
import { getTodos, toggleTodo, addTodo, deleteTodo } from '../services/todo.service';
import { TodoInputComponent } from './todo-input.component';
import { TodoListComponent, Todo } from './todo-list.component';
import { MessageComponent } from './message.component';
import CircularProgress from '@mui/material/CircularProgress';

export const TodoContainer: React.FC = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [messageError, setMessageError] = useState<string>('');
  const [isLoadingTodos, errorTodos, todosData, executorTodos] = useExecuteAsync();
  const [errorToggling, executorToggle] = useExecuteFireForget();
  const [errorAdding, executorAdd] = useExecuteFireForget();
  const [errorDeleting, executorDelete] = useExecuteFireForget();

  useEffect(() => {
    const { execute } = executorTodos as { execute: (callback: any, ...args: any[]) => Promise<any> };
    execute(getTodos);
  }, []);

  useEffect(() => {
    if (todosData) {
      setTodos(todosData as Todo[]);
    }

    if (errorTodos) {
      setMessageError(errorTodos.toString());
    }
  }, [todosData, errorTodos]);

  const handleMessageErrorClose = (event?: React.SyntheticEvent | Event, reason?: string) => {
    if (reason === 'clickway') {
      return;
    }

    setMessageError('');
  };

  const handleToggleCompleted = (id) => {
    const todosUpdated = todos.map((td) => {
      if (td.id === id) {
        td.completed = !td.completed;
      }
      return td;
    });

    const todoUpdated = todos.find((td) => td.id === id);
    const { execute } = executorToggle as { execute: (callback: any, ...args: any[]) => Promise<any> };
    execute(toggleTodo, id, todoUpdated!.completed)
      .then(() => {
        setTodos(todosUpdated);
      })
      .catch(() => setMessageError(errorToggling as string));
  };

  const handleOnAddTodo = (title: string) => {
    const todo = { title, completed: false, dueDate: new Date().toISOString() };
    const { execute } = executorAdd as { execute: (callback: any, ...args: any[]) => Promise<any> };
    execute(addTodo, todo)
      .then(getTodos)
      .then(setTodos)
      .catch(() => setMessageError(errorAdding as string));
  };

  const handleOnDeleteTodo = (id: number) => {
    const { execute } = executorDelete as { execute: (callback: any, ...args: any[]) => Promise<any> };
    execute(deleteTodo, id)
      .then(getTodos)
      .then(setTodos)
      .catch(() => setMessageError(errorDeleting as string));
  };

  return (
    <div style={{ textAlign: 'center' }}>
      <h3>Todos App</h3>
      {isLoadingTodos && !errorTodos ? (
        <CircularProgress />
      ) : (
        <>
          <TodoInputComponent onAddTodo={handleOnAddTodo} />
          <TodoListComponent todos={todos} onDeleted={handleOnDeleteTodo} toggleCompleted={handleToggleCompleted} />
        </>
      )}
      {messageError && (
        <MessageComponent
          message={messageError}
          severity="error"
          open={!!messageError}
          handleClose={handleMessageErrorClose}
        />
      )}
    </div>
  );
};
