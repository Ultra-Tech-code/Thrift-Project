import { ethers } from "hardhat";

async function main() {

  const Thrift = await ethers.deployContract("Thrift");

  await Thrift.waitForDeployment();

  console.log(`Thrift  deployed to ${Thrift.target}`);


//interact with contract
const thrift = await ethers.getContractAt("Thrift", Thrift.target);

const target = ethers.parseEther("100");
const duration = 60 * 60 * 24 * 7; // 7 days
const startTime = Math.round(Date.now() / 1000);
const endTime = startTime + duration;


//createGoal
const createGoalTx = await thrift.createGoal("buy car", target, startTime);
const createGoalReceipt = await createGoalTx.wait();
// const goalId = createGoalReceipt.events[0].args[0].toNumber();
console.log(`Goal created with id ${createGoalReceipt}`);



//getContribution
const contribution = await thrift.getContribution();
console.log(`Contribution: ${contribution.toString()}`);



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
