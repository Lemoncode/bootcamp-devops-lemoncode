import express from 'express';

export const topicsRoute = () => {
    const router = express.Router();

    router.get('/', (_, res) => {
        const topics: string[] = ['clothes', 'vehicles'];
        res.json(topics);
    });

    return router;
};
