const ERC721 = artifacts.require("./ERC721.sol"); // Use the name of your ERC721 contract

module.exports = function(deployer) {
  deployer.deploy(ERC721);
};