require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      blockGasLimit: 10000000,
    },
  },
  solidity: "0.8.0",
  networks: {
    arbitrum: {
      url: process.env.ARBITRUM_ENDPOINT,
      accounts: [process.emitWarning.PRIVATE_KEY]
    }
  }
};