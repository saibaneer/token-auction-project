// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";

contract AuctionFactory {

    enum PricingLogic {
        LinearFunction,
        QuadraticFunction,
        PolynomialFunction
    }
    using Clones for address;


    
    mapping(PricingLogic => address) public enumToPricingLogicAddress;

    constructor(){
        
    }


    //TO DO
    function createAuction(address _tokenAddress, uint256 numberOfTokens, uint256 startingPrice, PricingLogic _logic) external returns(address) {

    }

    // Add access control here
    function addPricingLogic(address _logicAddress, PricingLogic _logic) external {
        enumToPricingLogicAddress[_logic] = _logicAddress;
    }

}