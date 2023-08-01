const Migrations = artifacts.require("/Users/guarantable/bitbucket/smart-contract/klaytngreeter_test/contracts/Migrations.sol");
const KlaytnGreeter = artifacts.require("/Users/guarantable/bitbucket/smart-contract/klaytngreeter_test/contracts/KlaytnGreeter.sol");
module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(KlaytnGreeter, 'Hello, Guarantable');
};