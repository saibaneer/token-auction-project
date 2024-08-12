// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./internal_contracts/InternalAuctionFunctions.sol";

/// @title AuctionEntrypoint
/// @notice Provides the entry points for external interaction with the auction system.
contract AuctionEntrypoint is InternalAuction {
    /// @notice Initializes the auction with the provided parameters. 
    /// Since at least 9 items are needed to initialize the auction logic, passing them 
    /// individually would take up too much gas, since the cost of memory in function increases at O(n^2).
    /// Thus, using a single object paramter reduces gas, and avoids stack too deep errors.
    /// @dev Calls the internal `_initialize` function to set up the auction parameters.
    /// @param _params Struct containing all necessary parameters for auction creation.
    function initialize(AuctionCreationParams memory _params) external {
        _initialize(_params);
    }

    /// @notice Allows the auction creator to fund the auction by transferring the specified tokens to the contract.
    /// @dev The function uses the `msg.sender` to identify the caller and pass it to the internal `_fundAuction` function.
    function fundAuction() external {
        _fundAuction(msg.sender);
    }

    /// @notice Calculates the total cost for purchasing a specified number of tokens.
    /// @param unitsOfTokensToBuy The number of tokens the buyer wants to purchase.
    /// @return The total cost in the base currency (ETH or stablecoin) for the specified number of tokens.
    function amountDueForPurchase(
        uint256 unitsOfTokensToBuy
    ) external view returns (uint256) {
        uint256 purchasePrice = modelType == 0
            ? LinearPricingLogicLib.getAverageLinearPrice(
                unitsOfTokensToBuy,
                chargePerUnitToken,
                startingBidPrice,
                totalTokensSold
            )
            : QuadraticPricingLogicLib.calculateTotalPrice(
                unitsOfTokensToBuy,
                totalTokensSold,
                startingBidPrice,
                chargePerUnitToken
            );
        return purchasePrice;
    }

    /// @notice Allows a user to purchase tokens using a stablecoin.
    /// @dev The function uses the `msg.sender` to identify the caller and pass it to the internal `_buyTokensWithStableCoin` function.
    /// @param unitsOfTokensToBuy The number of tokens the buyer wants to purchase.
    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external {
        _buyTokensWithStableCoin(unitsOfTokensToBuy, msg.sender);
    }

    /// @notice Allows a user to claim their purchased tokens after the auction has ended.
    /// @dev The function calls the internal `_claimPurchasedTokens` function, passing the `msg.sender` as the caller.
    function claimPurchasedTokens() external {
        _claimPurchasedTokens(msg.sender);
    }

    /// @notice Allows the auction creator to withdraw any unsold tokens after the auction ends.
    /// @dev Access control should be added to restrict this function to the auction creator only.
    /// TO DO: Implement access control.
    function withdrawUnsoldTokens() external {
        _withdrawUnsoldTokens();
    }

    /// @notice Returns the amount of time left until the auction ends.
    /// @dev If the auction has already ended, the function returns 0.
    /// @return The number of seconds remaining until the auction ends.
    function timeLeftInAuction() external view returns (uint256) {
        return
            block.timestamp < auctionEndTime
                ? auctionEndTime - block.timestamp
                : 0;
    }
}
