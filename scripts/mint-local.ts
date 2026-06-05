import { network } from "hardhat";

async function main() {
  // Connect to the localhost network (your "turned node")
  const { ethers } = await network.create({
    network: "localhost",
  });

  const signers = await ethers.getSigners();
  
  // Based on ignition/modules/Bankeer.ts:
  // user1 (initialOwner) = signers[1]
  // user2 (treasury) = signers[2]
  // user3 (bank) = signers[3]
  const bank = signers[3];
  const receiver = signers[0]; // Minting to the first account for convenience

  const bankeerAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const bankeer = await ethers.getContractAt("Bankeer", bankeerAddress, bank);

  console.log(`Using Bank account: ${bank.address}`);
  console.log(`Minting tokens to: ${receiver.address}`);

  // Mint COIN (ID 1)
  console.log("Minting 1000 COINs...");
  const tx1 = await bankeer["mint(address,uint256,uint256,bytes)"](receiver.address, 1, 1000, "0x");
  await tx1.wait();
  console.log("Success: Minted 1000 COINs");

  // // Mint a new token (e.g., SWORD with ID 2)
  // // Note: Non-COIN tokens can only be minted once in this contract.
  // const tokenId = 2;
  // const price = ethers.parseEther("0.1"); // Example price in COINs? 
  // // Wait, the contract uses COINs as currency for buySWORD. 
  // // totalStorePrices[id] is set during minting.

  // console.log(`Minting Token ID ${tokenId} with price 10...`);
  // const tx2 = await bankeer["mint(address,uint256,uint256,uint256,bytes)"](
  //   bank.address, // Usually items are minted to the bank to be sold via buySWORD
  //   tokenId, 
  //   10, // amount
  //   10, // price in COINs
  //   "0x"
  // );
  // await tx2.wait();
  // console.log(`Success: Minted 10 items of ID ${tokenId} to Bank with price 10`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
