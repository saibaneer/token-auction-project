// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../libraries/LinearPricingLogicLibrary.sol";
import "../libraries/QuadraticPricingLogicLibrary.sol";
import "../interfaces/ISingleAuction.sol";
import {AuctionCreationParams, PricingLogic} from "../data_structures/UserDefinedTypes.sol";
import "../Storage.sol";

abstract contract InternalAuction is
    ISingleAuction,
    Initializable,
    Storage
{
    using SafeERC20 for IERC20;

    modifier onlyCreator() {
        require(msg.sender == creator, Errors.ACCESS_FORBIDDEN);
        _;
    }

    function _initialize(
        AuctionCreationParams memory _params
    ) internal initializer {
        totalNumberOfTokens = _params.numberOfTokens;
        startingBidPrice = _params.startingPrice;
        acceptableStableCoin = _params.acceptedStable;
        tokenAddress = _params.tokenAddress;
        creator = _params.creator;
        auctionStartTime = _params.auctionStartTime;
        auctionEndTime = _params.auctionEndTime;
        modelType = uint8(_params.logic);
    }

    function _fundAuction(address _caller) internal onlyCreator {
        require(IERC20(tokenAddress).balanceOf(_caller) >= totalNumberOfTokens, Errors.INSUFFICIENT_TOKEN_BALANCE);
        IERC20(tokenAddress).safeTransferFrom(_caller, address(this), totalNumberOfTokens);
    }

    function _setSlope(uint256 _m) internal onlyCreator {
        require(
            _m < 1 ether || _m > 0.01 ether,
            Errors.INVALID_RANGE
        );
        chargePerUnitToken = _m;
        emit SetSlope(chargePerUnitToken);
    }

    function _buyTokens(uint256 unitsOfTokensToBuy, address _caller) internal {
        require(IERC20(tokenAddress).balanceOf(address(this)) > 0 , Errors.INSUFFICIENT_TOKEN_BALANCE_IN_CONTRACT);
        require(chargePerUnitToken != 0, Errors.SET_CHARGE_PER_UNIT_TOKEN);
        require(unitsOfTokensToBuy > 0, Errors.BAD_AMOUNT);
        require((totalTokensSold + unitsOfTokensToBuy)*10**18 <= totalNumberOfTokens);
        require(block.timestamp >= auctionStartTime, Errors.AUCTION_IS_YET_TO_BEGIN);
        require(block.timestamp <= auctionEndTime, Errors.AUCTION_HAS_ENDED);

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

        require(
            msg.value >= purchasePrice,
            Errors.INSUFFICIENT_TOKEN_BALANCE
        );

        balances[_caller] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        // totalNumberOfTokens -= unitsOfTokensToBuy;
        uint256 amount = msg.value;

        //pay via base token
        (bool success, ) = address(this).call{value: amount}("");
        require(success, Errors.TRANSACTION_FAILED);
        emit BoughtTokens(_caller, unitsOfTokensToBuy, amount);
    }

    function _buyTokensWithStableCoin(
        uint256 unitsOfTokensToBuy,
        address _caller
    ) internal {
        require(chargePerUnitToken != 0, Errors.SET_CHARGE_PER_UNIT_TOKEN);
        require(unitsOfTokensToBuy > 0, Errors.BAD_AMOUNT);
        require((totalTokensSold + unitsOfTokensToBuy)*10**18 <= totalNumberOfTokens);
        require(block.timestamp >= auctionStartTime, Errors.AUCTION_IS_YET_TO_BEGIN);
        require(block.timestamp <= auctionEndTime, Errors.AUCTION_HAS_ENDED);
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

        require(
            IERC20(acceptableStableCoin).balanceOf(_caller) > purchasePrice,
            Errors.INSUFFICIENT_TOKEN_BALANCE
        );

        balances[_caller] += unitsOfTokensToBuy * 10**18;
        totalTokensSold += unitsOfTokensToBuy;
        // totalNumberOfTokens -= unitsOfTokensToBuy ;

        IERC20(acceptableStableCoin).safeTransferFrom(
            _caller,
            address(this),
            purchasePrice
        );
        emit BoughtTokensWithStableCoin(_caller, unitsOfTokensToBuy, purchasePrice, acceptableStableCoin);
    }

    function _claimPurchasedTokens(address _caller) internal {
        uint256 amountDue = balances[_caller];
        require(amountDue > 0, Errors.NO_TOKENS_TO_CLAIM);
        require(
            block.timestamp >= auctionEndTime,
            Errors.CLAIM_AFTER_AUCTION
        );

        // Adjust the amount due by the token's decimals
        amountDue = amountDue; // assuming the token has 18 decimals

        balances[_caller] = 0;
        // totalNumberOfTokens -= amountDue;
        IERC20(tokenAddress).safeTransfer(_caller, amountDue);
        emit ClaimedPurchasedTokens(_caller, amountDue, tokenAddress);
    }

    function _withdrawRemainingBaseToken() internal onlyCreator {
        uint amount = address(this).balance;
        (bool success, ) = payable(creator).call{value: amount}(
            ""
        );
        require(success, Errors.TRANSACTION_FAILED);
        emit WithdrewBaseTokens(msg.sender, amount);
    }

    function _withdrawUnsoldTokens() internal onlyCreator {
        uint256 amount = totalNumberOfTokens - (totalTokensSold * 10**18);
        IERC20(tokenAddress).safeTransfer(
            creator,
            amount
        );
        emit WithdrewUnsoldTokens(msg.sender, amount);
    }

}
