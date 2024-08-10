// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

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

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external;

    function withdrawUnsoldTokens() external;
}
