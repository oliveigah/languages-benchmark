require('dotenv').config({ path: './config/.env' });
const path = require('path');

module.exports = {
  MULTI_CORE: process.env.MULTI_CORE || false,
  ROOT_DATABASE_FOLDER: path.resolve('./persist'),
  MAIN_PORT: process.env.MAIN_PORT || 3000,
};
