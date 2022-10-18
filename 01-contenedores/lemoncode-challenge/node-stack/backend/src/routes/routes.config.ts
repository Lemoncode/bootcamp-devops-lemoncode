import { Application } from 'express';
import { topicsRoutes } from './topics.route';

export const routesInitialization = (app: Application) => {
    // TODO: Inject DAL
    app.use('/api/topics', topicsRoutes(null));
};