import Knex, { PgConnectionConfig } from 'knex';

type ConnectionParams = PgConnectionConfig & { dbVersion: string };

export const startConnection = ({ dbVersion: version, ...connection }: ConnectionParams) => {
  try {
    return Knex({
      client: 'pg',
      version,
      connection,
    });
  } catch (error) {
    throw error;
  }
};