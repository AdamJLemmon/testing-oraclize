pragma solidity ^0.4.15;

import './OraclizeAPI.sol';

/**
 * @title Testing Oraclize
 * Test contract to understand the basics of leveraging the Oraclize service.
 */
contract TestingOraclize is usingOraclize {
  uint public price_;

  event LogNewOraclizeQuery(string description);
  event LogCallback(uint price);

  /**
   * Constructor
   * @dev Set the proof type and storage location.
   * NOTE if you wish to make several queries it may be a good idea to make your
   * constructor payable and deploy the contract with an endowment so that many
   * queries may be made without having to send ether with each. Only the first
   * query is free.
   * ie. function TestingOraclize() payable {} and deployer.deploy(TestingOraclize, { value: 10e18 })
   */
  function TestingOraclize() {
    OAR = OraclizeAddrResolverI(0x23Ae7F929b1ec162EAE96c6958bD8D69809E3098);
    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
  }

  /**
   * Query kraken web api to retrieve the current eth / usd pairing.
   * Method is payable as only the first query is free! msg.value > oraclize fee for each
   * following query if the contract itself has an insiffucient balance.
   */
  function getETHUSDPrice() public payable {
    if (oraclize.getPrice("URL") > this.balance) {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");

    } else {
      LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
      oraclize_query("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
    }
  }

  /**
   * Oraclize callback.
   * @param _myid The query id.
   * @param _result The result of the query.
   * @param _proof Oraclie generated proof. Stored in ipfs in this case.
   * Therefore is the ipfs multihash.
   */
  function __callback(
    bytes32 _myid,
    string _result,
    bytes _proof
  ) public
  {
    require(msg.sender == oraclize_cbAddress());
    price_ = parseInt(_result, 6); // 6 decimal places

    LogCallback(price_);
  }
}
