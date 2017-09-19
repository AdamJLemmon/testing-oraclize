const TestingOraclize = artifacts.require("./TestingOraclize.sol");
const owner = web3.eth.accounts[0]

module.exports = deployer => {
  deployer.deploy(TestingOraclize, { from: owner, gas: 4e6 });
};
