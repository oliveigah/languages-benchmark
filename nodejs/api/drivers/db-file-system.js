const fs = require('fs');
const config = require('../../config/config');

const storeAsync = (id, value, folder) => {
  const buffer = Buffer.from(JSON.stringify(value));
  fs.writeFile(
    `${config.ROOT_DATABASE_FOLDER}/${folder}/${id}`,
    buffer,
    (err) => {
      if (err) throw err;
    },
  );
};

const storeSync = (id, value, folder) => {
  const buffer = Buffer.from(JSON.stringify(value));
  fs.writeFileSync(
    `${config.ROOT_DATABASE_FOLDER}/${folder}/${id}`,
    buffer,
  );

  return true;
};

const get = (id, folder) => {
  try {
    const resultBuffer = fs.readFileSync(
      `${config.ROOT_DATABASE_FOLDER}/${folder}/${id}`,
    );
    const result = Buffer.from(resultBuffer);
    return JSON.parse(result.toString());
  } catch (e) {
    return undefined;
  }
};

module.exports = {
  storeAsync,
  storeSync,
  get,
};
