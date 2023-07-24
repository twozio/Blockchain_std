const Ticket = artifacts.require("Ticket.sol");

module.exports = function (deployer) {
  // deployment steps
  deployer.deploy(Ticket);
};
