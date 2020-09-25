module.exports = class DataBaseInterface {
  constructor(driver) {
    this.driver = driver;
  }

  storeSync(id, value, folder) {
    return this.driver.storeSync(id, value, folder);
  }

  storeAsync(id, value, folder) {
    return this.driver.storeAsync(id, value, folder);
  }

  get(id, folder) {
    return this.driver.get(id, folder);
  }
};
