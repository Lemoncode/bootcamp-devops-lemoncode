import axios from 'axios';
import config from './config';

const { apiUrl } = config;

export const getTopics = (): Promise<void | string[]> => {
  return axios
    .get(`${apiUrl}/api/topics/`)
    .then((response) => response.data as string[])
    .catch(console.error);
};
