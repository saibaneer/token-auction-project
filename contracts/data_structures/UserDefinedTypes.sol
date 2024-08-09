// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

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

struct FundAuctionParams {
    address tokenAddress;
    uint256 numberOfTokens;
}

library Errors {

    string internal constant INVALID_RANGE = "Invalid range";
    string internal constant TRANSACTION_FAILED = "Transaction failed!";
    string internal constant INSUFFICIENT_TOKEN_BALANCE = "Insufficient Token balance";
    string internal constant BAD_AMOUNT = "You can't buy zero tokens";
    string internal constant ACCESS_FORBIDDEN = "Access Forbidden";
    string internal constant SET_CHARGE_PER_UNIT_TOKEN = "Set charge per unit token!";
    string internal constant NO_TOKENS_TO_CLAIM = "You have no tokens to claim!";
    string internal constant CLAIM_AFTER_AUCTION = "Claim is possible after auction is expired";
    string internal constant AUCTION_IS_YET_TO_BEGIN = "Auction is yet to begin!";
    string internal constant AUCTION_HAS_ENDED = "Auction has ended!";
    string internal constant INSUFFICIENT_TOKEN_BALANCE_IN_CONTRACT = "Insufficient Token balance in contract";

}