const express = require('express');
const database = require('../drivers/db-file-system');

const router = express.Router();

const depositUseCase = require('../use-cases/deposit');
const withdrawUseCase = require('../use-cases/withdraw');
const simulateBusyUseCase = require('../use-cases/simulate-busy')

router.post('/deposit', async (req, res) => {
  const { accountId, amount } = req.body;
  try {
    depositUseCase.dependencies = () => ({
      database,
    });
    const result = depositUseCase({ accountId, amount });
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `${error.name}: ${error.message}`,
    });
    console.log(error.stack);
  }
});

router.post('/withdraw', async (req, res) => {
  const { accountId, amount } = req.body;
  try {
    withdrawUseCase.dependencies = () => ({
      database,
    });
    const result = withdrawUseCase({ accountId, amount });

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `${error.name}: ${error.message}`,
    });
    console.log(error.stack);
  }
});

router.post('/simulate-busy', async (req, res) => {
  const { counter } = req.body;
  try {
    const result = simulateBusyUseCase({counter});
    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `${error.name}: ${error.message}`,
    });
    console.log(error.stack);
  }
});


module.exports = router;
