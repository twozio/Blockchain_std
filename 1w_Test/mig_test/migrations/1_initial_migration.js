const Migrations = artifacts.require("./Migrations.sol");
const MyERC721Card = artifacts.require("./MyERC721Card.sol");
module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(MyERC721Card)
};