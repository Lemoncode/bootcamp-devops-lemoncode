import express, { Application } from 'express';
import cors from 'cors';
import { routesInitialization } from '../routes';

export const createApp = () => {
  const app: Application = express();

  // TODO: Set up cors.
  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  routesInitialization(app);

  return app;
};