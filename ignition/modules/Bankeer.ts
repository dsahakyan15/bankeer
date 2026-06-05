import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("BankeerModule", (m) => {

    const user1 = m.getAccount(1);
    const user2 = m.getAccount(2);
    const user3 = m.getAccount(3);   

    const bankeer = m.contract("Bankeer", [user1, user2, user3]);
    const auction = m.contract("Auction", [bankeer]);


  return { bankeer, auction };
});
