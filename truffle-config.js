const HDWalletProvider = require('@truffle/hdwallet-provider');
require("dotenv").config();
const mnemonic = process.env.MNEMONIC;
const token = process.env.INFURA_TOKEN;

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "999",
      networkCheckTimeout: 999999,
    },
    rinkeby: {
      network_id: "4",
      provider: () => {
        return new HDWalletProvider(mnemonic, token);
      },
      gasPrice: 75000000000, // 75 Gwei
      networkCheckTimeout: 10000000,
      skipDryRun: true,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.1",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  },

  db: {
    enabled: false
  }
};
