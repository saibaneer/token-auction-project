// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


library QuadraticPricingLogicLib {
 


    // Calculate the price of the nth token using a quadratic bonding curve
    function getPriceOfNthToken(uint256 n, uint256 initialPrice, uint256 priceMultiplier) public pure returns (uint256) {
        return initialPrice + (priceMultiplier * (n ** 2));
    }

    // Calculate the sum of squares for the range from n to m
    function sumOfSquares(uint256 n, uint256 m) public pure returns (uint256) {
        uint256 sumM = (m * (m + 1) * (2 * m + 1)) / 6;
        uint256 sumN = (n * (n + 1) * (2 * n + 1)) / 6;
        return sumM - sumN;
    }

    // Calculate the total price for a given amount of tokens without using loops
    function calculateTotalPrice(uint256 amount, uint256 totalTokensSold, uint256 startingBidPrice, uint256 priceMultiplier) public pure returns (uint256) {
        uint256 n = totalTokensSold;
        uint256 m = n + amount;

        // Calculate the sum of squares between n and m
        uint256 sumSquares = sumOfSquares(n, m);

        // Total price is the initial price multiplied by the amount, plus the quadratic sum multiplied by the price multiplier
        uint256 totalPrice = amount * startingBidPrice + priceMultiplier * sumSquares;

        return totalPrice;
    }
}