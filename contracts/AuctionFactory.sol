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

    constructor() {}

    //TO DO
    function createAuction(
        address _tokenAddress,
        uint256 numberOfTokens,
        uint256 startingPrice,
        PricingLogic _logic,
        address _acceptedStable,
        address _creator
    ) external returns (address) {
        
    }
}

// Didnt use a library because once in production you can't change logic, but external contract allows for it
