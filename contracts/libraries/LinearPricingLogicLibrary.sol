// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title LinearPricingLogicLib
/// @notice Provides functions to calculate prices based on a linear pricing curve.
/// @dev This library is used to implement linear pricing in an auction or token sale.
library LinearPricingLogicLib {

    /// @notice Calculates the average price for purchasing a specified number of tokens using a linear pricing curve.
    /// @dev The function assumes that prices increase linearly with each additional token sold.
    ///      The calculation is based on the formula for the sum of an arithmetic series:
    ///      Total Cost = (Number of Tokens) * (Average Price)
    ///      Average Price = (First Token Price + Last Token Price) / 2
    ///      First Token Price = startingBidPrice + (chargePerUnitToken * totalTokensSold)
    ///      Last Token Price = First Token Price + ((unitOfTokensToBuy - 1) * chargePerUnitToken)
    /// @param unitOfTokensToBuy The number of tokens that the user intends to buy.
    /// @param chargePerUnitToken The price increment for each additional token.
    /// @param startingBidPrice The starting price of the first token.
    /// @param totalTokensSold The total number of tokens sold before this purchase.
    /// @return The total cost for the specified number of tokens.
    function getAverageLinearPrice(
        uint256 unitOfTokensToBuy,
        uint256 chargePerUnitToken,
        uint256 startingBidPrice,
        uint256 totalTokensSold
    ) internal pure returns (uint256) {

        // Calculate the price of the first token in this purchase based on the starting price and the number of tokens sold so far.
        uint256 currentPrice = startingBidPrice + (chargePerUnitToken * totalTokensSold);
        
        // Calculate the price of the last token in this purchase.
        // The last token price is the price of the first token in this purchase plus (unitsOfTokensToBuy - 1) * chargePerUnitToken.
        uint256 priceOfNextToken = currentPrice + ((unitOfTokensToBuy - 1) * chargePerUnitToken);
        
        // The total cost is derived from the formula for the sum of an arithmetic series:
        // Total Cost = (Number of Tokens) * (First Token Price + Last Token Price) / 2
        // This formula calculates the total cost by multiplying the number of tokens by the average price of the first and last tokens.
        return unitOfTokensToBuy * (priceOfNextToken + currentPrice) / 2;
    }
}