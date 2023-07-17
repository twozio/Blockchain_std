const TicketExample = artifacts.require("TicketExample.sol");

module.exports = function (deployer) {
  // deployment steps
  deployer.deploy(TicketExample, "Guratable Ticket Example", "GTE");
};
