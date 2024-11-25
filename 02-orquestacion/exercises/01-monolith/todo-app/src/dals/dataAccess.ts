import Knex from 'knex';

export interface ConnectionParams {
  port: number;
  host: string;
  user: string;
  password: string;
  database: string;
  dbVersion: string;
}

export const startConnection = (connection: ConnectionParams) => {
  try {
    return Knex({
      client: 'pg',
      connection: {
        ...connection,
      },
    });
  } catch (error) {
    console.error(error);
    throw error;
  }
};
