import express from 'express';
import config from '../config';
import { createApp } from './create-server-app';

export const initServer = () => {
    const app: express.Application = createApp();
    const { app: { host, port } } = config;

    app.listen(port, host, () => console.log(`Server listening on http://${host}:${port}`));
};
