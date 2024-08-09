// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./internal_contracts/InternalAuctionFunctions.sol";

contract AuctionEntrypoint is InternalAuction {
    function initialize(
        AuctionCreationParams memory _params
    ) external {
        _initialize(_params);
    }

    function setSlope(uint256 _slope) external {
        _setSlope(_slope);
    }

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

    function buyTokens(uint256 unitsOfTokensToBuy) external payable {
        _buyTokens(unitsOfTokensToBuy, msg.sender);
    }

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external {
        _buyTokensWithStableCoin(unitsOfTokensToBuy, msg.sender);
    }

    function claimPurchasedTokens() external {
        _claimPurchasedTokens(msg.sender);
    }

    //TO DO: Add Access control
    function withdrawRemainingBaseToken() external {
        _withdrawRemainingBaseToken();
    }

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external {
        _withdrawUnsoldTokens();
    }
}
