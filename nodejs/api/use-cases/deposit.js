const lodash = require('lodash');
const DatabaseInterface = require('../interfaces/database-interface');


const useCase = ({ accountId, amount }) => {
  const { database } = useCase.dependencies();

  const currentAccount = database.get(accountId, 'accounts') || { id: accountId, balance: 0 };

  const resultAccount = lodash.cloneDeep(currentAccount);

  resultAccount.balance += amount;

  const saved = database.storeSync(accountId, resultAccount, 'accounts');

  if (saved) return { ...resultAccount, success: true, message: 'Operation completed successfully'};
  throw new Error('Could not finish the operation');
};

useCase.dependencies = () => ({
  database: new DatabaseInterface({}),
});

module.exports = useCase;
