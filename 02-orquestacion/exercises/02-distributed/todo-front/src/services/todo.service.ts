import axios from 'axios';

export interface TodoModel {
  id: number;
  title: string;
  completed: boolean;
  dueDate: string;
}

console.log(process.env.API_HOST);

const host = () => (process.env.API_HOST) ? process.env.API_HOST : ''; 

const handleError = (err) => {
  console.log(err);
  throw 'error from server';
};

export const getTodos = () =>
  axios
    .get(`${host()}/api/`)
    .then(({ data }) => data)
    .catch(handleError);

export const addTodo = (todo: TodoModel) =>
  axios
    .post(`${host()}/api/`, todo)
    .then(({ data }) => data)
    .catch(handleError);

export const deleteTodo = (id: number) =>
  axios
    .delete(`${host()}/api/${+id}/`)
    .then(({ data }) => data)
    .catch(handleError);

export const toggleTodo = (id: number, completed: boolean) => 
    axios.patch(`${host()}/api/${+id}/`, { completed })
      .then(({data}) => data)
      .catch(handleError);
