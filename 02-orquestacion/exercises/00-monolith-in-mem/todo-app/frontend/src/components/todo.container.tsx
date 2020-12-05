import React, { useEffect, useState } from 'react';

import { useExecuteAsync } from '../hooks/use-execute-async';
import { useExecuteFireForget } from '../hooks/use-execute-fire-forget';
import { getTodos, toggleTodo, addTodo, deleteTodo } from '../services/todo.service';
import { TodoInputComponent } from './todo-input.component';
import { TodoListComponent, Todo } from './todo-list.component';
import { MessageComponent } from './message.component';
import CircularProgress from '@material-ui/core/CircularProgress';

export const TodoContainer: React.FC = () => {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [messageError, setMessageError] = useState<string>('');
  const [isLoadingTodos, errorTodos, todosData, executorTodos] = useExecuteAsync();
  const [errorToggling, executorToggle] = useExecuteFireForget();
  const [errorAdding, executorAdd] = useExecuteFireForget();
  const [errorDeleting, executorDelete] = useExecuteFireForget();

  useEffect(() => {
    const { execute } = executorTodos;
    execute(getTodos);
  }, []);

  useEffect(() => {
    if (todosData) {
      setTodos(todosData);
    }

    if (errorTodos) {
      setMessageError(errorTodos.toString());
    }
  }, [todosData, errorTodos]);

  const handleMessageErrorClose = (event?: React.SyntheticEvent, reason?: string) => {
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
    const { execute } = executorToggle;
    execute(toggleTodo, id, todoUpdated.completed)
      .then(() => {
        setTodos(todosUpdated);
      })
      .catch(() => setMessageError(errorToggling));
  };

  const handleOnAddTodo = (title: string) => {
    const todo = { title, completed: false, dueDate: new Date().toISOString() };
    const { execute } = executorAdd;
    execute(addTodo, todo)
      .then(getTodos)
      .then(setTodos)
      .catch(() => setMessageError(errorAdding));
  };

  const handleOnDeleteTodo = (id: number) => {
    const { execute } = executorDelete;
    execute(deleteTodo, id)
      .then(getTodos)
      .then(setTodos)
      .catch(() => setMessageError(errorDeleting));
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
