var Minting = artifacts.require("../contract/Minting.sol");

module.exports = function(deployer) {
  // deployment steps
    deployer.deploy(Minting, "guarantable", "test");

};
