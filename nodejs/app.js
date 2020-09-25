const express = require('express');
const account = require('./api/handlers/handlers');
const config = require('./config/config');

exports.app = () => {
  const app = express();
  app.use(express.json());
  app.use('/', account);
  const port = config.MAIN_PORT;
  app.listen(port);
  console.log('info', `Nodejs running on port ${port}`);
};
