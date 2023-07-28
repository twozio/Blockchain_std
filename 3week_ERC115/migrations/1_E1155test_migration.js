const E1155test = artifacts.require("E1155test.sol");

module.exports = function (deployer) {
  // deployment steps
    deployer.deploy(E1155test);
};