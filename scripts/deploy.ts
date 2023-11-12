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

//-------------interact with contract------------//
const thrift = await ethers.getContractAt("Thrift", Thrift.target);
const usdt = await ethers.getContractAt("USDT", USDT.target);


//get block.timestamp
const blockTime = await ethers.provider.getBlock("latest");
const target = ethers.parseEther("100");
const duration = 60 * 60 * 24 * 7; // 7 days
const interval = 60 * 60 * 24 * 1; // 1 days

console.log(interval, "interval")
const startTime = 60 * 60 * 24 * 2 ; // 2 days



//createGoal
const singlethrifttx = await thrift.connect(user1).createSingleThrift(usdt.target, "Buy a new car", target, duration, startTime, interval);
const singlethriftReceipt = await singlethrifttx.wait();
//console.log(singlethriftReceipt)

// get allSingle created
const allSingle = await thrift.allSingle();
const singlethriftAddress = allSingle[0];
console.log(allSingle)

//get userSingleThrift created
const userSingle = await thrift.userSingleThrift(user1.address);
console.log(userSingle)



//------------------usdt intercation-------------//
//mint
const minttx = await usdt.mintToken(user1.address, target)
               await usdt.mintToken(deployer.address, target)
await minttx.wait();

//approve
const approvetx = await usdt.connect(user1).approve(singlethriftAddress, target)
                  await usdt.connect(deployer).approve(singlethriftAddress, target)
await approvetx.wait()



//----Interact with the singlethrift contract
const singlethrift = await ethers.getContractAt("Singlethrift", singlethriftAddress);

//getAccount
const getAccounttx = await singlethrift.getAccount()
//console.log(getAccounttx, "get account result")

// hardhat time travel
await ethers.provider.send("evm_increaseTime", [startTime]); // in first cycle
//save
let amount = await singlethrift.amountToSavePerInterval()
console.log(amount, "amount")


const savetx = await singlethrift.connect(user1).save(ethers.toBigInt(amount))
await savetx.wait();
//console.log(savetx, "save result")

await ethers.provider.send("evm_increaseTime", [86400]); //in second cylce
await singlethrift.connect(deployer).save(ethers.toBigInt(amount)) 

await ethers.provider.send("evm_increaseTime", [172800]); //in fourth cylce
await singlethrift.connect(deployer).save(ethers.toBigInt(amount)) 

const singlethriftWhenSave = await usdt.balanceOf(singlethriftAddress)
console.log(singlethriftWhenSave.toString(), "thrift balance when saved")

const userBalanceSaved = await usdt.balanceOf(user1.address)
console.log(userBalanceSaved.toString(), "user balance when saved")

// hardhat time travel
await ethers.provider.send("evm_increaseTime", [60 * 60 * 24 * 10]);

//withdraw
const withdrawtx = await singlethrift.connect(user1).withdraw()
await withdrawtx.wait();
//console.log(withdrawtx, "withdraw result")

//csheck for emergency withdrawal
// const ewithdrawtx = await singlethrift.connect(user1).emergencyWithdrawal()
// await ewithdrawtx.wait();
// console.log(ewithdrawtx, "Emergency withdraw result")

// const saveagain = await singlethrift.connect(user1).save(ethers.parseEther("80")) //revert cos the account has been deleted
// await saveagain.wait();
// console.log(saveagain, "save again result")

//amountToSavePerInterval
const amountToSavePerInterval = await singlethrift.amountToSavePerInterval()
console.log(amountToSavePerInterval.toString(), "amountToSavePerInterval")
console.log(Number(amountToSavePerInterval) / 1e18, "amountToSavePerInterval in usdt")


//user balance
const userBalance = await usdt.balanceOf(user1.address)
console.log(userBalance.toString(), "user balance")

//thrift balance
const thriftBalance = await usdt.balanceOf(singlethriftAddress)
console.log(thriftBalance.toString(), "singlethriftAddress balance")

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
