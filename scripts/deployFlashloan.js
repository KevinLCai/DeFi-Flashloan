const hre = require("hardhat");

async function main() {
  const Flashloan = await hre.ethers.getContractFactory("Flashloan");
  const flashloan = await Flashloan.deploy("0x5E52dEc931FFb32f609681B8438A51c675cc232d");

  await flashloan.deployed();
  console.log("Flahloan contract deployed: ", flashloan.address); 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
