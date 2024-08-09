// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


library LinearPricingLogicLib {
 

    function getAverageLinearPrice(uint256 unitOfTokensToBuy, uint256 chargePerUnitToken, uint256 startingBidPrice, uint256 totalTokensSold) internal pure returns(uint256){
        uint256 currentPrice = startingBidPrice + (chargePerUnitToken * totalTokensSold);
        uint256 priceOfNextToken = currentPrice + ((unitOfTokensToBuy-1) * chargePerUnitToken);
        return unitOfTokensToBuy * (priceOfNextToken + currentPrice)/2;
    }
}