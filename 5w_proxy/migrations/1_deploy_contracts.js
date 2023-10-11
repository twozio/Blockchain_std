const ProxyCopyright = artifacts.require('ProxyCopyright');
const Copyright = artifacts.require('Copyright');

module.exports = async function(deployer) {
    // Deploy the Copyright implementation contract first
    await deployer.deploy(Copyright);
    const copyright = await Copyright.deployed();
    
    // Then deploy the proxy with the address of the Copyright implementation
    await deployer.deploy(ProxyCopyright, copyright.address);
};