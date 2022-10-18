import express from 'express';

export const topicsRoutes = (topicsServiceDAL: any) => {
    const router = express.Router();

    router.get('/', (_, res) => {
        // TODO: Use topicsServiceDAL
        res.json(['topic A', 'topic B']);
    });

    router.get('/:id', (_, res) => {
        // TODO: Use topicsServiceDAL
        res.json('topic A');
    });

    router.post('/', (req, res) => {
        // TODO: Use topicsServiceDAL
        const echo = req.body;
        res.json(echo);
    });

    router.put('/:id', (req, res) => {
        const echo = req.body;
        res.json(echo);
    });

    router.delete('/:id', (req, res) => {
        res.json();
    });

    return router;
} 