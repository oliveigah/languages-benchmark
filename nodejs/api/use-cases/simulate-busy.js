const lodash = require('lodash');
const DatabaseInterface = require('../interfaces/database-interface');


const useCase = ({ counter }) => {
  let result = 0;
  for(let i = 0; i <= counter; i++) {
    result = i
  }
  return result
};

useCase.dependencies = () => ({
  database: new DatabaseInterface({}),
});

module.exports = useCase;
