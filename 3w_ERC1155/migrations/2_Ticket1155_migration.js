const Ticket1155 = artifacts.require("Ticket1155.sol");

module.exports = function (deployer) {
  // deployment steps
    deployer.deploy(Ticket1155);
};