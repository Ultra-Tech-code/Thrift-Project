import { ethers } from "hardhat";

async function main() {
  // const deployer = (await ethers.getSigners())[0];
  const[deployer, user1, user2, user3, user4] = await ethers.getSigners();

  //Deploy USDT contract
  const mockToroNg = await ethers.deployContract("mockToroNg");
  await mockToroNg.waitForDeployment();
  console.log(`mockToroNg deployed to ${mockToroNg.target}`);


  // Deploy Thrift contract
  const Thrift = await ethers.deployContract("Thrift");
  await Thrift.waitForDeployment();
  console.log(`Thrift  deployed to ${Thrift.target}`);

//-------------interact with contract------------//
const thrift = await ethers.getContractAt("Thrift", Thrift.target);
const mockToro = await ethers.getContractAt("mockToroNg", mockToroNg.target);

//params
const target = ethers.parseEther("100");
const duration = 60 * 60 * 24 * 10; // 10 days
const interval = 60 * 60 * 24 * 2; // 2 days
const startTime = 60 * 60 * 24 * 2 ; // 2 days

//createGoal
const groupthrifttx = await thrift.connect(user1).createGroupThrift(mockToroNg.target, 4, [user1.address, user2.address, user3.address, user4.address], "Buy a new car", target, duration, startTime, interval);
const groupthriftReceipt = await groupthrifttx.wait();
console.log(groupthriftReceipt)

// get allSingle created
const allGroup = await thrift.allGroup();
const groupthriftAddress = allGroup[0];
console.log(allGroup)

//get userSingleThrift created
const userGroup = await thrift.userGroupThrift(user1.address);
console.log(userGroup)



//------------------usdt intercation-------------//
//mint
const minttx = await mockToro.mintToken(user1.address, target)
               await mockToro.mintToken(deployer.address, target)
               await mockToro.mintToken(user2.address, target)
               await mockToro.mintToken(user3.address, target)
await minttx.wait();

//approve
const approvetx = await mockToro.connect(user1).approve(groupthriftAddress, target)
                  await mockToro.connect(deployer).approve(groupthriftAddress, target)
                  await mockToro.connect(user2).approve(groupthriftAddress, target)
                  await mockToro.connect(user3).approve(groupthriftAddress, target)
await approvetx.wait()



//----Interact with the groupthrift contract
const groupthrift = await ethers.getContractAt("Groupthrift", groupthriftAddress);

//getAccount
const getAccounttx = await groupthrift.getAccount()
console.log(getAccounttx, "get account result")

// hardhat time travel
await ethers.provider.send("evm_increaseTime", [startTime]);

//save
let amount = ethers.parseEther("100")
const savetx = await groupthrift.connect(user1).save(user1.address)
               //await groupthrift.connect(deployer).save(deployer.address) //revert NOT MEMBER
await savetx.wait();


await ethers.provider.send("evm_increaseTime", [startTime]); //in second cylce
await groupthrift.connect(user2).save(user2.address)

await ethers.provider.send("evm_increaseTime", [startTime]); //in fourth cylce
await groupthrift.connect(user3).save(user3.address)


console.log(savetx, "save result")

const singlethriftWhenSave = await mockToro.balanceOf(groupthriftAddress)
console.log(singlethriftWhenSave.toString(), "thrift balance when saved")

const userBalanceSaved = await mockToro.balanceOf(user1.address)
console.log(userBalanceSaved.toString(), "user balance when saved")

// hardhat time travel
await ethers.provider.send("evm_increaseTime", [duration]);
const blockTime = await ethers.provider.getBlock("latest");
console.log(blockTime?.timestamp, "block time")

//withdraw
const withdrawtx = await groupthrift.connect(user1).withdraw(user1.address)
await withdrawtx.wait();
console.log(withdrawtx, "withdraw result")

//csheck for emergency withdrawal
// const ewithdrawtx = await groupthrift.connect(user1).emergencyWithdrawal()
// await ewithdrawtx.wait();
// console.log(ewithdrawtx, "Emergency withdraw result")

// const saveagain = await groupthrift.connect(user1).save(ethers.parseEther("80")) //revert cos the account has been deleted
// await saveagain.wait();
// console.log(saveagain, "save again result")


//user balance
const userBalance = await mockToro.balanceOf(user1.address)
console.log(userBalance.toString(), "user balance")

//thrift balance
const thriftBalance = await mockToro.balanceOf(groupthriftAddress)
console.log(thriftBalance.toString(), "groupthriftAddress balance")

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
