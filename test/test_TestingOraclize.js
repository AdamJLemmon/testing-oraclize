const TestingOraclize = artifacts.require('./TestingOraclize.sol');

contract('TestingOraclize', accounts => {

  it('should get the ETH / USD pairing from the Kraken web api.', async () => {
    const testingOraclize = await TestingOraclize.new()
    let response = await testingOraclize.getETHUSDPrice()

    // Confirm new oraclize query event emitted
    let log = response.logs[0]
    assert.equal(log.event, 'LogNewOraclizeQuery', 'LogNewOraclizeQuery not emitted.')
    assert.equal(log.args.description, 'Oraclize query was sent, standing by for the answer..', 'Incorrect description emitted.')

    // Wait for the callback to be invoked by oraclize and the event to be emitted
    const logNewPriceWatcher = promisifyLogWatch(testingOraclize.LogCallback({ fromBlock: 'latest' }));

    log = await logNewPriceWatcher;
    assert.equal(log.event, 'LogCallback', 'LogCallback not emitted.')
    assert.isNotNull(log.args.price, 'Price returned was null.')

    console.log('Success! Current price is: ' + log.args.price.toNumber() / 10e5 + ' USD/ETH')
  });
});

/**
 * Helper to wait for log emission.
 * @param  {Object} _event The event to wait for.
 */
function promisifyLogWatch(_event) {
  return new Promise((resolve, reject) => {
    _event.watch((error, log) => {
      _event.stopWatching();
      if (error !== null)
        reject(error);

      resolve(log);
    });
  });
}
