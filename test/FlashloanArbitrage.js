const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FlashloanArbitrage", function () {
  let flashloanArbitrage;

  before(async function () {
    flashloanArbitrage = await ethers.getContractAt(
      "FlashloanArbitrage",
      "0x0000000000000000000000000000000000000000"
    );
  });

  it("should execute a trade successfully", async function () {
    const result = await flashloanArbitrage.executeTrade(
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "1000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      "IUniswapV3Router",
      "IUniswapV3Router",
      "1000000000000000000"
    );
    expect(result).to.be.true;
  });
});