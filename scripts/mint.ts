import { network } from "hardhat";

async function main(){

const { ethers } = await network.create({
  network: "localhost",
});

console.log("Sending transaction using the OP chain type");

  const signers = await ethers.getSigners();
  const bank = signers[3];
  const receiver = signers[0]; 
  
  const bankeerAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
  const bankeer = await ethers.getContractAt("Bankeer",bankeerAddress,bank);


  console.log("Sending L2 transaction,(Coins)");
  let tx = await bankeer.mint(receiver.address, 1,1000000,'0x');
  await tx.wait();


  console.log("Sending L2 transaction,(Coins)");
  tx = await bankeer.mint(signers[1].address, 1,1000000,'0x');
  await tx.wait();

  console.log("Sending L2 transaction,(Tokens)");
  tx = await bankeer.mint(receiver.address, 2,50,'0x');
  await tx.wait();

  console.log("L2,setting price of token");
  tx = await bankeer.setPrice(2,10000);
  await tx.wait();

}


main().catch((e)=> {
console.error(e);
process.exitCode = 1;

})

console.log("Transaction sent successfully");
