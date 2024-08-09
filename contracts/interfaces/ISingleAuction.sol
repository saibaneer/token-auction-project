// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../dataStructures/UserDefinedTypes.sol";

interface ISingleAuction {
    function initialize(
        UserDefinedTypes.AuctionCreationParams memory _params
    ) external;

    function amountDueForPurchase(
        uint256 unitsOfTokensToBuy
    ) external view returns (uint256);

    function buyTokens(uint256 unitsOfTokensToBuy) external payable;

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external;

    //TO DO: Add Access control
    function withdrawRemainingBaseToken() external;

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external;
}
