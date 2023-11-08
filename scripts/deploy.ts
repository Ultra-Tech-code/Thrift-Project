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

const target = ethers.parseEther("100");
const duration = 60 * 60 * 24 * 7; // 7 days
const startTime = Math.round(Date.now() / 1000);
const endTime = startTime + duration;

//createGoal
const singlethrifttx = await thrift.connect(user1).createSingleThrift(usdt.target, "Buy a new car", target, duration, startTime);
const singlethriftReceipt = await singlethrifttx.wait();
console.log(singlethriftReceipt)

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
await minttx.wait();

//approve
const approvetx = await usdt.connect(user1).approve(singlethriftAddress, target)
await approvetx.wait()



//----Interact with the singlethrift contract
const singlethrift = await ethers.getContractAt("Singlethrift", singlethriftAddress);

//getAccount
const getAccounttx = await singlethrift.getAccount()
console.log(getAccounttx, "get account result")


//save
let amount = ethers.parseEther("100")
const savetx = await singlethrift.save(amount)
await savetx.wait();

//withdraw
const withdrawtx = await singlethrift.withdraw()
await withdrawtx.wait();


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
