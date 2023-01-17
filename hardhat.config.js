require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      blockGasLimit: 10000000,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.0",
      },
      {
        version: "0.7.0",
      },
      {
        version: "0.8.10",
        options: {} // Optionally add more options
      }
    ],
  },
  networks: {
    arbitrum: {
      url: process.env.ARBITRUM_ENDPOINT,
      accounts: process.emitWarning.PRIVATE_KEY
    }
  }
};