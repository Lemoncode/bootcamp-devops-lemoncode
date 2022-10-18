if (process.env.NODE_ENV === 'development') {
    require('dotenv').config;
}

export default {
    database: {
        url: process.env.DATABASE_URL,
    },
    app: {
        host: process.env.HOST || '0.0.0.0',
        port: +process.env.PORT || 5000
    }
}