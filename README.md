# Testing Oraclize with Truffle
This repo is an example of how to write and test a contract that utilizes Oraclize on a private network locally.  This is intended to serve as a fully integrated starting point for developers that wish to leverage the Oraclize service.


## Quick Start
1. Clone Me
```
$ git clone git@github.com:AdamJLemmon/testing-oraclize.git
$ cd testing-oraclize
```

2. Start your local client

_In another terminal window. We are using testrpc here but any other client is also supported. The remainder of this document assumes the client is running at localhost:8545_

Your client, testrpc here, should be configured to use a static set of account addresses, as the bridge will be dependent upon a specified address for deploying its required contracts on your private chain. Therefore if you want those addresses to stay constant, between testrpc runs, you should be running testrpc with some re-usable addresses. You can do this by adding the --mnemonic flag when starting it, and using the same mnemonic phrase over when restarting testrpc, to ensure it generates the same Oraclize OAR (OraclizeAddressResolver), which you will need to use in the next step.

Start testrpc using a specific mnemonic phrase, and take note of the index of the last available account, (you can use any for this, but I recommend the last one, as it's an account that shouldn't be used in tests, also make sure enough other accounts were generated for you to be able to do tests using).

Since 50 accounts are generated, the last address' index is 49.

```
$ testrpc --mnemonic testingOraclize --accounts 50
```

3. Start the bridge

_In a separate terminal window._

Node version < 7.0.0 is required. [NVM](https://github.com/creationix/nvm) provides an excellent interface to manage several versions of node.  Install nvm and switch to node version 6.9.1.
```
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.4/install.sh | bash
```
Confirm the install was successful.
```
$ command -v nvm
nvm
```
If you do not see nvm output then simply close and re-open your terminal window.  If this does not work then refer to the nvm link above for further instructions.
````
$ nvm install 6.9.1
$ nvm use 6.9.1
```

Now start the bridge. Note specifying account 49.

```
testing-oraclize $ cd ethereum-bridge
ethereum-bridge $
ethereum-bridge $ node bridge -a 49
```

Once the bridge has booted up successfully you should see the following output:

```
Please add this line to your contract constructor:

OAR = OraclizeAddrResolverI(0x145437eac36aeacee0c135c9015fff316ba938ed);
```

Update ./contracts/TestingOraclize#L25 with the above line.  Now as long as the same mnemonic is used when starting your client and the same account when starting the bridge than this line will not need to be changed. (Do remember to remove the OAR variable from your constructor before production, this is just for testing, in production it will automatically fetch the OAR depending on the chain you're running it, currently the Mainnet, Ropsten, and browser-solidity VM environment are supported.)

4. Execute the contract test suite

_Don't forget to switch your node version back first._

```
testing-oraclize $ nvm use 8.0.0
testing-oraclize $ truffle test
```

And you are able to query the Kraken web api from your smart contract utilizing a local chain!
