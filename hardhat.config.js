require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},

    sepolia: {
      url: process.env.SEPOLIA_RPC,
      accounts: [process.env.WALLET_PRIV]
    },

    polygonMumbai: {
      url: process.env.MUMBAI_RPC,
      accounts: [process.env.WALLET_PRIV]
    }
  },
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  mocha: {
    timeout: 40000
  }
};
