import { ethers } from "hardhat";

async function main() {
  // const deployer = (await ethers.getSigners())[0];
  const[deployer, user1, user2, user3] = await ethers.getSigners();

  //Deploy USDT contract
  const USDT = await ethers.deployContract("USDT");
  await USDT.waitForDeployment();
  console.log(`USDT deployed to ${USDT.target}`);


  // Deploy Thrift contract
  const Thrift = await ethers.deployContract("Thrift");
  await Thrift.waitForDeployment();
  console.log(`Thrift  deployed to ${Thrift.target}`);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});