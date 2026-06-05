
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Bankeer is ERC1155, ERC1155Burnable,ERC1155Supply, Ownable {

    error UnburnableToken();
    error UnmintableToken();
    error TokenIsAlreadyMinted();
    error FunctionDisabled();
    error TokenDoesntExist();
    error TokenDoesntExistInBank();
    error SizeDismatch();
    error BankAndTreasuryCantBeTheSame();
    error UnauthorizedUser();



    modifier onlyBank(){
        if(msg.sender == bankAddress){
            _;
        }else revert UnauthorizedUser();
    }
    modifier exceptBank(){
        if(msg.sender != bankAddress){
            _;
        }else revert UnauthorizedUser();
    }
    modifier availableBalance(address who ,uint balance, uint price,uint tokenId){
        if(balance >= price){
            _;
        }else revert ERC1155InsufficientBalance(who,balance,price,tokenId);
    }

    // Addresses
    address private treasuryAddress;
    address private bankAddress;
    address private auctionContractAddress;


    // COIN's
    uint public constant COIN = 1;
    // SWORD's
    uint256[] public totalStoreVariety;
    mapping(uint256 => uint256) public totalStorePrices;

    constructor(
        address initialOwner,
        address treasuryAddress_,
        address bankAddress_) 
    ERC1155("ipfs://bafybeiftdcklrhvaxwnakffv4crv4eafes6pyl2elptgpqxxy3pq2oklnm/{id}.json") Ownable(initialOwner) {
        if(treasuryAddress_ == bankAddress_)revert BankAndTreasuryCantBeTheSame();
        treasuryAddress = treasuryAddress_;
        bankAddress = bankAddress_;
    }

    function buySWORD (uint id,bytes calldata data)public virtual availableBalance(msg.sender,balanceOf(msg.sender, 1),totalStorePrices[id],1) {
            if(balanceOf(bankAddress,id) > 0){
                _safeTransferFrom(msg.sender, bankAddress, 1,totalStorePrices[id] , data);
                _safeTransferFrom(bankAddress, msg.sender, id, 1, data);
            }else revert TokenDoesntExistInBank();
    }
            
    function buySWORDBatch(uint id,uint amount,bytes calldata data)public virtual availableBalance(msg.sender,balanceOf(msg.sender, 1),(totalStorePrices[id] * amount),1){
            if(balanceOf(bankAddress,id) >= amount){
            _safeTransferFrom(msg.sender, bankAddress, 1,(totalStorePrices[id] * amount) , data);
            _safeTransferFrom(bankAddress, msg.sender, id, amount, data);
        }else revert TokenDoesntExistInBank();
    }
    
    function setPrice(uint256 id,uint value)public virtual onlyBank{
        if(id != COIN && id != 0){
            totalStorePrices[id] = value;
        }else revert TokenDoesntExist();
    }
    function setPriceBatch(uint[] calldata ids,uint[] calldata values)public virtual onlyBank{

        if (ids.length != values.length) {
            revert ERC1155InvalidArrayLength(ids.length, values.length);
        }
        
        for(uint i = 0;i<ids.length;i++){
            uint el = ids[i];
            if(el != COIN && el != 0 && exists(el)){
                uint elPrice = values[i];
                totalStorePrices[el] = elPrice;
            }else revert TokenDoesntExist();
        }
    }

    function getPrice(uint256 id)view public returns (uint256){
        if(id != 0){
            if(id == COIN){
                // TODO Price from LPool
                return 17;
            }else if(exists(id)){
                return totalStorePrices[id];
            }
        }
    }
    function getPriceBatch(uint[] calldata ids) public view returns(uint[] memory){
    uint validCount = 0;
    for(uint i = 0;i<ids.length;i++){
        uint el = ids[i];
        if(el != 0){
            validCount++;
        }
    }

    if(validCount == 0) revert TokenDoesntExist();

    uint[] memory values = new uint[](validCount);
    uint currentId = 0;
    for(uint i = 0;i<ids.length;i++){
        uint el = ids[i];
        if(el != 0){
            if(el == COIN){
                // TODO Price from LPool
                values[currentId] = 17;
            }else if(exists(el)){
                values[currentId] = totalStorePrices[el];
            }
            currentId++;
        }
    }
    return values;
    }

    function setAuctionContractAddress(address newContractAddress)public onlyOwner() { 
        auctionContractAddress = newContractAddress;
    }


    /// OVEERRIDED FUNCTIONS

    

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._update(from, to, ids, values);
    }



    function mint(address to, uint256 id, uint256 amount, bytes memory data)
        public
        onlyBank
    { 

    /// if it doesnt exist yet in market
    if (id == 0) revert UnmintableToken();
    if (exists(id) && id != COIN) revert TokenIsAlreadyMinted();
    if(!exists(id) && id!= COIN){
            totalStoreVariety.push(id);
        }
    _mint(to, id, amount, data);
    }

    // for setting price 

    function mint(address to, uint256 id, uint256 amount,uint price, bytes memory data)
        public
        onlyBank
    { 

    /// if it doesnt exist yet in market
    if (id == 0) revert UnmintableToken();
    if (exists(id) && id != COIN) revert TokenIsAlreadyMinted();
    if(!exists(id) && id!= COIN){
            totalStoreVariety.push(id);
            totalStorePrices[id] = price;
        }
    _mint(to, id, amount, data);
    }



    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data)
        public
        onlyBank
    {

    require(ids.length == amounts.length,SizeDismatch());
    uint validCount = 0;
    uint[] memory tempIds = new uint[](ids.length);
    uint[] memory tempValues = new uint[](ids.length);

    for(uint i = 0;i < ids.length;i++){
        // NFT doesnt exist yet 
        // [0,1,3,5,7,1]
        if(ids[i] != 0){
            if(ids[i] == COIN){
                tempIds[validCount] = COIN;
                tempValues[validCount] = amounts[i];
                validCount++;
            }else if(!exists(ids[i])){
                totalStoreVariety.push(ids[i]);
                tempIds[validCount] = ids[i];
                tempValues[validCount] = amounts[i];
                validCount++;
            }
        }
    }
    if(validCount == 0) revert SizeDismatch();
    // Filtered IDs,Values
    uint[] memory filIds = new uint[](validCount);
    uint[] memory filValues = new uint[](validCount);
    if(validCount < ids.length){
    for(uint i = 0;i < validCount;i++){
            filIds[i] = (tempIds[i]);
            filValues[i] = (tempValues[i]);
    }
    _mintBatch(to, filIds, filValues, data);

    }else{
    _mintBatch(to, ids, amounts, data);

    }
    }

    function mintBatch(
        address to, 
        uint256[] calldata ids, 
        uint256[] calldata amounts,
        uint256[] calldata prices, 
        bytes calldata data)  public  onlyBank
    {

    uint length = ids.length;
    if(length != amounts.length || length != prices.length) revert SizeDismatch();
    if(length == 0) revert SizeDismatch();

    for(uint i = 0;i < length; ++i){
        uint id = ids[i];
        if(id == 0) revert UnmintableToken();

        if(id != COIN){
            if(exists(id)) revert TokenIsAlreadyMinted();

            totalStoreVariety.push(id);
            totalStorePrices[id] = prices[i];
        }
    }
    _mintBatch(to, ids, amounts, data);

    }
    
    function burn(address acc,uint256 id,uint256 value)public virtual override {
        if(id != COIN || id == 0) revert UnburnableToken();
        if(acc == owner()){
            super.burn(acc,id,value);
        }else{
            
            safeTransferFrom(acc, treasuryAddress, id, value,'');
        }
    }
    function burnBatch(address acc, uint256[] memory ids, uint256[] memory values)public virtual override{
        revert FunctionDisabled();
    }

}
