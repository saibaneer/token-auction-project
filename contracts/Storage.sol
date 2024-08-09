// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;



contract Storage {
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalPrice);

    uint256 public totalNumberOfTokens;
    uint256 public totalTokensSold;
    uint256 public chargePerUnitToken; 
    uint256 public startingBidPrice; 
    address public acceptableStableCoin;
    address public tokenAddress;
    address public creator;
    uint256 public auctionStartTime;
    uint256 public auctionEndTime;
    uint8 public modelType;

    

    mapping(address => uint256) public balances;

}