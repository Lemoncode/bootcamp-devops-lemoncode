import { knex, Knex } from 'knex';
import config from '../config';

const { database } = config;

let db: Knex;

export const startConnection = () => {
  try {
    db = knex({
      client: 'pg',
      connection: {
        database: database.database,
        host: database.host,
        port: database.port,
        user: database.user,
        password: database.password,
      },
      pool: {
        min: database.poolMin || 1,
        max: database.poolMax || 2,
      },
    });
  } catch (error) {
    throw error;
  }
};

export const closeConnection = async () => {
  try {
    await db.destroy();
  } catch (error) {
    throw error;
  }
};

export const getDbReference = (): Knex => db;
