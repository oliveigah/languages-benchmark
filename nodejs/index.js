const cluster = require('cluster');
const os = require('os');
const fs = require('fs');
const config = require('./config/config');
const runExpressServer = require('./app');

function createDatabaseFolders() {
  const folders = ['accounts', 'teste'];
  folders.forEach((folderName) => {
    try {
      fs.mkdirSync(
        `${config.ROOT_DATABASE_FOLDER}/${folderName}`,
        { recursive: true },
      );
    } catch (e) {
      console.log(e.message);
    }
  });
}

console.log('info', `MULTI CORE: ${config.MULTI_CORE}`);
createDatabaseFolders();

if (config.MULTI_CORE === false) {
  runExpressServer.app();
} else {
  if (cluster.isMaster) {
    const cpuCount = os.cpus().length;
    for (let j = 0; j < cpuCount; j++) {
      cluster.fork();
    }
  } else {
    runExpressServer.app();
  }
  cluster.on('exit', (worker) => {
    console.log(`Worker ${worker.id} died'`);
    console.log('Staring a new one...');
    cluster.fork();
  });
}
