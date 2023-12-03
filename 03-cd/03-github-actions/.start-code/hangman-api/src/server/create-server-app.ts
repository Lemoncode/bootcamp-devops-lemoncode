import express from 'express';
import cors from 'cors';
import { routesInitialization } from '../routes';

export const createApp = () => {
  const app: express.Application = express();

  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  routesInitialization(app);

  return app;
};
