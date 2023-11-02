const ERC721 = artifacts.require("./ERC721.sol");
const ProxyERC721 = artifacts.require("./ProxyERC721.sol"); // Use the name of your ERC721Proxy contract

module.exports = function(deployer) {
  deployer.deploy(ProxyERC721, ERC721.address, "guarantable", "GUT");
};