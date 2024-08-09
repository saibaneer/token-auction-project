// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;



library UserDefinedTypes {

    enum PricingLogic {
        LinearFunction,
        QuadraticFunction,
        PolynomialFunction
    }

    struct AuctionCreationParams {
        address tokenAddress;
        uint256 numberOfTokens;
        uint256 startingPrice;
        address acceptedStable;
        address creator;
        uint256 auctionStartTime;
        uint256 auctionEndTime;
        PricingLogic logic;
    }


    string internal constant INVALID_RANGE = "Invalid range";
    string internal constant TRANSACTION_FAILED = "Transaction failed!";
    string internal constant INSUFFICIENT_TOKEN_BALANCE = "Insufficient Token balance";
    string internal constant BAD_AMOUNT = "You can't buy zero tokens";
    string internal constant ACCESS_FORBIDDEN = "Access Forbidden";

}