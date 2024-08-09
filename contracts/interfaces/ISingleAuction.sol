// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../data_structures/UserDefinedTypes.sol";

interface ISingleAuction {

    event BoughtTokens(address indexed caller, uint256 tokensBought, uint256 amountPaid);
    event BoughtTokensWithStableCoin(address indexed caller, uint256 tokensBought, uint256 amountPaid, address paymentCurrency);
    event WithdrewBaseTokens(address indexed caller, uint256 amount);
    event WithdrewUnsoldTokens(address indexed caller, uint256 amount);
    event ClaimedPurchasedTokens(address indexed caller, uint256 tokensClaimed, address tokenAddress);
    event SetSlope(uint256 indexed slope);

    function initialize(
        AuctionCreationParams memory _params
    ) external;

    function amountDueForPurchase(
        uint256 unitsOfTokensToBuy
    ) external view returns (uint256);

    // function buyTokens(uint256 unitsOfTokensToBuy) external payable;

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external;

    //TO DO: Add Access control
    // function withdrawRemainingBaseToken() external;

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external;
}
