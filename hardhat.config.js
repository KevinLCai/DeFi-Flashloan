require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      blockGasLimit: 10000000,
    },
  },
  solidity: "0.8.0",
};