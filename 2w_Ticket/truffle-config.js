const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    baobab: {
      provider: () => {
        return new HDWalletProvider("ab848d2762863ed7aba465c52a8c0c0b23a7c882c933f90372f249c36f6972a7", "https://public-en-baobab.klaytn.net");
      },
      network_id: '1001', //Klaytn baobab testnet's network id
    }
  },
  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },
  compilers: {
    solc: {
      version: "0.8.17",      // Fetch exact version from solc-bin (default: truffle's version)
    }
  },
};
