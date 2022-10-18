if (process.env.NODE_ENV === 'development') {
    require('dotenv').config;
}

export default {
    database: {
        url: process.env.DATABASE_URL || 'mongodb://localhost:27017',
    },
    app: {
        host: process.env.HOST || 'localhost',
        port: +process.env.PORT || 5000
    }
}