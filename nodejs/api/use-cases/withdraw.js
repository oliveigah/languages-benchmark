const lodash = require('lodash');
const DatabaseInterface = require('../interfaces/database-interface');

const useCase = ({ accountId, amount }) => {
  const { database } = useCase.dependencies();

  const currentAccount = database.get(accountId, 'accounts') || { id: accountId, balance: 0 };

  const resultAccount = lodash.cloneDeep(currentAccount);

  const newBalance = currentAccount.balance - amount;

  if (newBalance < 0) throw new Error('Saldo insuficiente');

  resultAccount.balance = newBalance;

  const saved = database.storeSync(accountId, resultAccount, 'accounts');

  if (saved) return { ...resultAccount, success: true };
  throw new Error('Não foi possivel realizar a operação');
};

useCase.dependencies = () => ({
  database: new DatabaseInterface({}),
});

module.exports = useCase;
