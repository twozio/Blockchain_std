const HDWalletProvider = require("truffle-hdwallet-provider-klaytn");

module.exports = {
  networks: {
    baobab: {
      provider: () => { return new HDWalletProvider('adb5de8d95958cd5c7f7934dfdf6389753f357016ec383fe8dfb5f4c0dd88b32', "https://public-en-baobab.klaytn.net/") },
      network_id: '1001', //Klaytn baobab testnet's network id
      gas: '5000000',
      gasPrice: null
    }
  },

  compilers: {
    solc: {
      version: "0.8.20",      // Fetch exact version from solc-bin (default: truffle's version)
    }
  },
};
