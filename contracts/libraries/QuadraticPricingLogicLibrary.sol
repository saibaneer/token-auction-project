// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title QuadraticPricingLogicLib
/// @notice Provides functions to calculate prices based on a quadratic pricing curve.
/// @dev This library is used to implement quadratic pricing in an auction or token sale.
library QuadraticPricingLogicLib {

    /// @notice Calculates the price of the nth token using a quadratic bonding curve.
    /// @dev The price increases quadratically with each subsequent token.
    ///      The formula used is: Price(n) = initialPrice + priceMultiplier * (n^2)
    ///      where n is the position of the token in the sequence.
    /// @param n The position of the token in the sequence (starting from 1).
    /// @param initialPrice The initial price of the first token.
    /// @param priceMultiplier The multiplier that affects how quickly the price increases.
    /// @return The price of the nth token.
    function getPriceOfNthToken(
        uint256 n,
        uint256 initialPrice,
        uint256 priceMultiplier
    ) internal pure returns (uint256) {
        return initialPrice + (priceMultiplier * (n ** 2));
    }

    /// @notice Calculates the sum of squares for a range of integers from n to m.
    /// @dev This function uses the mathematical formula for the sum of squares:
    ///      Sum of squares = (m * (m + 1) * (2m + 1)) / 6
    ///      This is applied to both m and n, and the result is the difference between the two.
    ///      The sum of squares formula is used to calculate the total cost in a quadratic pricing model.
    /// @param n The starting integer (exclusive).
    /// @param m The ending integer (inclusive).
    /// @return The sum of squares from (n+1) to m.
    function sumOfSquares(uint256 n, uint256 m) internal pure returns (uint256) {
        uint256 sumM = (m * (m + 1) * (2 * m + 1)) / 6;
        uint256 sumN = (n * (n + 1) * (2 * n + 1)) / 6;
        return sumM - sumN;
    }

    /// @notice Calculates the total price for purchasing a given amount of tokens using a quadratic pricing curve.
    /// @dev This function avoids the use of loops by leveraging the sum of squares formula.
    ///      The total cost is calculated as:
    ///      Total Cost = amount * startingBidPrice + priceMultiplier * sumOfSquares(n, m)
    ///      where n is the number of tokens sold before this purchase and m is the total number of tokens after the purchase.
    /// @param amount The number of tokens to purchase.
    /// @param totalTokensSold The total number of tokens sold before this purchase.
    /// @param startingBidPrice The starting price for each token.
    /// @param priceMultiplier The multiplier affecting how the price increases with each token.
    /// @return The total cost for purchasing the specified number of tokens.
    function calculateTotalPrice(
        uint256 amount,
        uint256 totalTokensSold,
        uint256 startingBidPrice,
        uint256 priceMultiplier
    ) internal pure returns (uint256) {
        uint256 n = totalTokensSold; // The number of tokens sold before this purchase.
        uint256 m = n + amount; // The total number of tokens after this purchase.

        // Calculate the sum of squares for the range from n+1 to m
        uint256 sumSquares = sumOfSquares(n, m);

        // The total price is calculated as the sum of the starting price for all tokens plus the sum of the quadratic increases.
        uint256 totalPrice = amount * startingBidPrice + priceMultiplier * sumSquares;

        return totalPrice;
    }
}