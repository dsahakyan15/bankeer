// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;


import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


/// sword idn pti automat ga , nuyny amounty 

contract Auction is ERC1155Holder{


    error InvalidTimeAmount();
    error InvalidBidAmount();
    error TimeIsUp();
    error TimeIsntEndYet();
    error AuctionClosedAlready();
    error AuctionResolvedAlready();
    error InvalidUser();
    error OnlySwordsOnSale();


    event AuctionCreated(
        uint indexed aucId,
        uint indexed swordId,
        address seller,
        uint timeEnd,
        uint amount);
    event AuctionCanceled(
        uint indexed aucId,
        address indexed seller);
    event AuctionClosed(
        uint indexed aucId,
        address indexed seller);
    event AuctionResolved(
        uint indexed aucId,
        address indexed seller);
    event BuyRequest(
        uint indexed aucId,
        address indexed buyer,
        uint amount
    );



    enum AuctionEvent {Open,End}

    struct AuctionModel {
        address owner;
        uint SWORD_ID;
        uint timeEnd;
        uint amount;
        uint highestBid;
        address highestBidder;
        AuctionEvent state;
    }

    address storeAddress;
    uint public nextAuctionId = 0;
    mapping(uint => AuctionModel) public AuctionList;
    modifier onlySeller(uint aucId){
        if(AuctionList[aucId].owner == msg.sender){
            _;
        }else revert InvalidUser();
    }
    modifier exceptSeller(uint aucId){
        if(AuctionList[aucId].owner != msg.sender){
            _;
        }else revert InvalidUser();
    }

    modifier isTimeAvailable(uint aucId){
        if(block.timestamp < AuctionList[aucId].timeEnd){
            _;
        }
        else{
            revert TimeIsUp();
        }
    }
    modifier isAuctionOpen(uint aucId){
        if(AuctionList[aucId].state == AuctionEvent.Open){
            _;
        }else{
            revert AuctionClosedAlready();
        }
    }

    constructor(address storeAddress_){
        storeAddress = storeAddress_;
    }

    function createAuc(uint duration,uint swordId,uint amount,uint startingBid)public virtual{

        require(duration < (365*1 days),InvalidTimeAmount());
        require(swordId != 0 && swordId != 1,OnlySwordsOnSale());
        require(startingBid != 0,InvalidBidAmount());
        address seller = msg.sender;
        uint timeEnd = block.timestamp + duration;


        IERC1155(storeAddress).safeTransferFrom(msg.sender,address(this),swordId,amount,'');

        AuctionList[nextAuctionId] = AuctionModel({
            owner:seller,
            SWORD_ID:swordId,
            timeEnd:timeEnd,
            amount:amount,
            highestBid:startingBid,
            highestBidder:address(0),
            state:AuctionEvent.Open
        });

        emit AuctionCreated(nextAuctionId, swordId, seller, timeEnd, amount);
        nextAuctionId++;
    }

    function buyRequest(uint aucId,uint amount)public exceptSeller(aucId)  isTimeAvailable(aucId) isAuctionOpen(aucId) virtual{

        require(amount > AuctionList[aucId].highestBid,InvalidBidAmount());

        address prevBidder = AuctionList[aucId].highestBidder;
        uint prevBid = AuctionList[aucId].highestBid;

        AuctionList[aucId].highestBid = amount;
        AuctionList[aucId].highestBidder = msg.sender;

        //transfer enq anum poxy mer hashvin
        IERC1155(storeAddress).safeTransferFrom(msg.sender,address(this),1,amount,'');

        //veradarznum enq ancaci poxy 
        if(prevBidder != address(0)){
            IERC1155(storeAddress).safeTransferFrom(address(this),prevBidder,1,prevBid,'');
        }


        emit BuyRequest(aucId, msg.sender, amount);
    }

    function resolveAuc(uint aucId)public virtual  isAuctionOpen(aucId){
        AuctionModel storage auction = AuctionList[aucId];
        if(block.timestamp < auction.timeEnd){
            revert TimeIsntEndYet();
        }
        auction.state = AuctionEvent.End;

        if(auction.highestBidder != address(0)){
            IERC1155(storeAddress).safeTransferFrom(address(this),auction.owner,1,auction.highestBid,'');
            IERC1155(storeAddress).safeTransferFrom(address(this),auction.highestBidder,auction.SWORD_ID,auction.amount,'');
        }else{
            IERC1155(storeAddress).safeTransferFrom(address(this),auction.owner,auction.SWORD_ID,auction.amount,'');
        }

        emit AuctionResolved(aucId,AuctionList[aucId].owner);
        
    }


    function cancelAuc(uint aucId) onlySeller(aucId) isTimeAvailable(aucId) isAuctionOpen(aucId) public {
        AuctionModel storage auction = AuctionList[aucId];
        
        auction.state = AuctionEvent.End;
        IERC1155(storeAddress).safeTransferFrom(address(this),auction.owner,auction.SWORD_ID,auction.amount,'');

        if(auction.highestBidder != address(0)){
            IERC1155(storeAddress).safeTransferFrom(address(this),auction.highestBidder,1,auction.highestBid,'');
        }

        emit AuctionCanceled(aucId,auction.owner);
    }

    function prematureClose(uint aucId) onlySeller(aucId) isTimeAvailable(aucId) isAuctionOpen(aucId) public {
        AuctionModel storage auction = AuctionList[aucId];

        auction.state = AuctionEvent.End;

        if(auction.highestBidder != address(0)){
            IERC1155(storeAddress).safeTransferFrom(address(this),auction.owner,1,auction.highestBid,'');
            IERC1155(storeAddress).safeTransferFrom(address(this),auction.highestBidder,auction.SWORD_ID,auction.amount,'');
        }else{
            IERC1155(storeAddress).safeTransferFrom(address(this),auction.owner,auction.SWORD_ID,auction.amount,'');
        }

        emit AuctionClosed(aucId,auction.owner);

    }
}
