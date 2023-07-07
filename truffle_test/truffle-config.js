const HDWalletProvider = require("truffle-hdwallet-provider-klaytn");

const mnemonic = "mountains supernatural bird ...";

module.exports = {
  networks: {
    // development: {
    //   host: "localhost",
    //   port: 8651,
    //   network_id: "*" // Match any network id
    // },
    // klaytn: {
    //   provider: () => {
    //     const pks = JSON.parse(fs.readFileSync(path.resolve(__dirname)+'/privateKeys.js'))

    //     return new HDWalletProvider(pks, "http://localhost:8651", 0, pks.length)
    //   },
    //   network_id: '1001', //Klaytn baobab testnet's network id
    //   gas: '8500000',
    //   gasPrice: null
    // },
    // kasBaobab: {
    //   provider: () => {
    //     const option = {
    //       headers: [
    //         { name: 'Authorization', value: 'Basic ' + Buffer.from(accessKeyId + ':' + secretAccessKey).toString('base64') },
    //         { name: 'x-chain-id', value: '1001' }
    //       ],
    //       keepAlive: false,
    //     }
    //     return new HDWalletProvider(privateKey, new Caver.providers.HttpProvider("https://node-api.klaytnapi.com/v1/klaytn", option))
    //   },
    //   network_id: '1001', //Klaytn baobab testnet's network id
    //   gas: '8500000',
    //   gasPrice:'25000000000'
    // },
    // kasCypress: {
    //   provider: () => {
    //     const option = {
    //       headers: [
    //         { name: 'Authorization', value: 'Basic ' + Buffer.from(accessKeyId + ':' + secretAccessKey).toString('base64') },
    //         { name: 'x-chain-id', value: '8217' }
    //       ],
    //       keepAlive: false,
    //     }
    //     return new HDWalletProvider(cypressPrivateKey, new Caver.providers.HttpProvider("https://node-api.klaytnapi.com/v1/klaytn", option))
    //   },
    //   network_id: '8217', //Klaytn baobab testnet's network id
    //   gas: '8500000',
    //   gasPrice:'25000000000'
    // },
    baobab: {
      provider: () => { return new HDWalletProvider('adb5de8d95958cd5c7f7934dfdf6389753f357016ec383fe8dfb5f4c0dd88b32', "https://public-en-baobab.klaytn.net/") },
      network_id: '1001', //Klaytn baobab testnet's network id
      gas: '18500000',
      gasPrice: null
    }
    // cypress: {
    //   provider: () => { return new HDWalletProvider(privateKey, "http://your.cypress.en:8551") },
    //   network_id: '8217', //Klaytn mainnet's network id
    //   gas: '8500000',
    //   gasPrice: null
    // }
  }
};