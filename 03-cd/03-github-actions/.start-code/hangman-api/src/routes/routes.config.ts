import { Application } from 'express';
import { topicsRoute } from './topics.route';

export const routesInitialization = (app: Application) => {
    app.use('/api/topics', topicsRoute());
};
