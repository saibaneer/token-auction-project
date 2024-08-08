// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

enum PricingLogic {
        LinearFunction,
        QuadraticFunction,
        PolynomialFunction
    }

library Structs {

    struct AuctionCreationParams {
        address tokenAddress;
        uint256 numberOfTokens;
        uint256 startingPrice;
        PricingLogic logic;
        address acceptedStable;
        address creator;
    }

}