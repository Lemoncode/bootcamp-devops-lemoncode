if(process.env.NODE_ENV === 'development') {
  require('dotenv').config();
}

export default {
  database: {
    isActive: process.env.DATA_BASE_ACTIVE,
    host: process.env.DATABASE_HOST,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    port: +process.env.DATABASE_PORT!,
    database: process.env.DATABASE_NAME,
    poolMin: +process.env.DATABASE_POOL_MIN!,
    poolMax: +process.env.DATABASE_POOL_MAX!,
  },
  app: {
    port: +process.env.PORT! || 3000,
    host: process.env.HOST || '0.0.0.0'
  }
};
