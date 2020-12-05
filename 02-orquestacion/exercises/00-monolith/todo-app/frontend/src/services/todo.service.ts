import axios from 'axios';

export interface TodoModel {
  id: number;
  title: string;
  completed: boolean;
  dueDate: string;
}

const handleError = (err) => {
  console.log(err);
  throw 'error from server';
};

export const getTodos = () =>
  axios
    .get('/api/')
    .then(({ data }) => data)
    .catch(handleError);

export const addTodo = (todo: TodoModel) =>
  axios
    .post('/api/', todo)
    .then(({ data }) => data)
    .catch(handleError);

export const deleteTodo = (id: number) =>
  axios
    .delete(`/api/${+id}/`)
    .then(({ data }) => data)
    .catch(handleError);

export const toggleTodo = (id: number, completed: boolean) => 
    axios.patch(`/api/${+id}/`, { completed })
      .then(({data}) => data)
      .catch(handleError);
