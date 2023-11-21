import { ethers } from "hardhat";

async function main() {
  // const deployer = (await ethers.getSigners())[0];
  const[deployer, user1, user2, user3] = await ethers.getSigners();

  //Deploy USDT contract
  const mockToroNg = await ethers.deployContract("mockToroNg");
  await mockToroNg.waitForDeployment();
  console.log(`mockToro deployed to ${mockToroNg.target}`);


  // Deploy Thrift contract
  const Thrift = await ethers.deployContract("Thrift");
  await Thrift.waitForDeployment();
  console.log(`Thrift  deployed to ${Thrift.target}`);

//-------------interact with contract------------//
const thrift = await ethers.getContractAt("Thrift", Thrift.target);
const mockToro = await ethers.getContractAt("mockToroNg", mockToroNg.target);


//get block.timestamp
const blockTime = await ethers.provider.getBlock("latest");
const target = ethers.parseEther("100");
const duration = 60 * 60 * 24 * 7; // 7 days
const interval = 60 * 60 * 24 * 1; // 1 days

console.log(interval, "interval")
const startTime = 60 * 60 * 24 * 2 ; // 2 days



//createGoal
const singlethrifttx = await thrift.connect(user1).createSingleThrift(mockToroNg.target, "Buy a new car", target, duration, startTime, interval);
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
const minttx = await mockToro.mintToken(user1.address, target)
               await mockToro.mintToken(deployer.address, target)
await minttx.wait();

//approve
const approvetx = await mockToro.connect(user1).approve(singlethriftAddress, target)
                  await mockToro.connect(deployer).approve(singlethriftAddress, target)
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


// const savetx = await singlethrift.connect(user1).save(ethers.toBigInt(amount))
const savetx = await singlethrift.connect(user1).save()
await savetx.wait();
console.log(savetx, "save result")

await ethers.provider.send("evm_increaseTime", [86400]); //in second cylce
await singlethrift.connect(user1).save() 

await ethers.provider.send("evm_increaseTime", [172800]); //in fourth cylce
await singlethrift.connect(user1).save() 

console.log("after save")
const singlethriftWhenSave = await mockToro.balanceOf(singlethriftAddress)
console.log(singlethriftWhenSave.toString(), "thrift balance when saved")

const userBalanceSaved = await mockToro.balanceOf(user1.address)
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
const userBalance = await mockToro.balanceOf(user1.address)
console.log(userBalance.toString(), "user balance")

//thrift balance
const thriftBalance = await mockToro.balanceOf(singlethriftAddress)
console.log(thriftBalance.toString(), "singlethriftAddress balance")

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
