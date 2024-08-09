// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../../Storage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../../libraries/LinearPricingLogicLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../interfaces/ISingleAuction.sol";
import "../../data_structures/UserDefinedTypes.sol";

contract LinearAuction is ISingleAuction, Initializable, Storage {
    using SafeERC20 for IERC20;

    modifier onlyCreator() {
        require(msg.sender == creator, Errors.ACCESS_FORBIDDEN);
        _;
    }

    function initialize(
        AuctionCreationParams memory _params
    ) public initializer {
        totalNumberOfTokens = _params.numberOfTokens;
        startingBidPrice = _params.startingPrice;
        acceptableStableCoin = _params.acceptedStable;
        tokenAddress = _params.tokenAddress;
        creator = _params.creator;
        auctionStartTime = _params.auctionStartTime;
        auctionEndTime = _params.auctionEndTime;
    }

    function setSlope(uint256 _m) external {
        require(_m < 1 ether || _m > 0.01 ether, Errors.INVALID_RANGE);
        chargePerUnitToken = _m;
        emit SetSlope(chargePerUnitToken);
    }

    function amountDueForPurchase(
        uint256 _unitsOfTokensToBuy
    ) external view returns (uint256) {
        return
            LinearPricingLogicLib.getAverageLinearPrice(
                _unitsOfTokensToBuy,
                chargePerUnitToken,
                startingBidPrice,
                totalTokensSold
            );
    }

    function buyTokens(uint256 unitsOfTokensToBuy) external payable {
        require(chargePerUnitToken != 0, "Set charge per unit token!");
        require(unitsOfTokensToBuy > 0, Errors.BAD_AMOUNT);
        require(totalTokensSold + unitsOfTokensToBuy <= totalNumberOfTokens);
        require(block.timestamp >= auctionStartTime, "Auction is yet to being");
        require(block.timestamp <= auctionEndTime, "Auction is over!");
        uint256 purchasePrice = LinearPricingLogicLib.getAverageLinearPrice(
            unitsOfTokensToBuy,
            chargePerUnitToken,
            startingBidPrice,
            totalTokensSold
        );

        require(
            msg.value >= purchasePrice,
            Errors.INSUFFICIENT_TOKEN_BALANCE
        );

        balances[msg.sender] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        totalNumberOfTokens -= unitsOfTokensToBuy;
        uint256 amount = msg.value;
        //pay via base token
        (bool success, ) = address(this).call{value: amount}("");
        require(success, Errors.TRANSACTION_FAILED);
        emit BoughtTokens(msg.sender, unitsOfTokensToBuy, amount);
    }

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external {
        require(chargePerUnitToken != 0, "Set charge per unit token!");
        require(unitsOfTokensToBuy > 0, Errors.BAD_AMOUNT);
        require(totalTokensSold + unitsOfTokensToBuy <= totalNumberOfTokens);
        require(block.timestamp >= auctionStartTime, "Auction is yet to being");
        require(block.timestamp <= auctionEndTime, "Auction is over!");
        uint256 purchasePrice = LinearPricingLogicLib.getAverageLinearPrice(
            unitsOfTokensToBuy,
            chargePerUnitToken,
            startingBidPrice,
            totalTokensSold
        );
        require(
            IERC20(acceptableStableCoin).balanceOf(msg.sender) > purchasePrice,
            Errors.INSUFFICIENT_TOKEN_BALANCE
        );

        balances[msg.sender] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        totalNumberOfTokens -= unitsOfTokensToBuy;

        IERC20(acceptableStableCoin).safeTransferFrom(
            msg.sender,
            address(this),
            purchasePrice
        );
        emit BoughtTokensWithStableCoin(msg.sender, unitsOfTokensToBuy, purchasePrice, acceptableStableCoin);
    }

    function claimPurchasedTokens() external {
        uint256 amountDue = balances[msg.sender];
        require(amountDue > 0, Errors.NO_TOKENS_TO_CLAIM);
        require(
            block.timestamp >= auctionEndTime,
            Errors.CLAIM_AFTER_AUCTION
        );

        balances[msg.sender] = 0;
        IERC20(tokenAddress).safeTransfer(msg.sender, amountDue);
        emit ClaimedPurchasedTokens(msg.sender, amountDue, tokenAddress);
    }

    //TO DO: Add Access control
    function withdrawRemainingBaseToken() external onlyCreator {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(creator).call{value: address(this).balance}(
            ""
        );
        require(success, Errors.TRANSACTION_FAILED);

        emit WithdrewBaseTokens(msg.sender, amount);
    }

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external onlyCreator {
        uint256 amount = totalNumberOfTokens - totalTokensSold;
        IERC20(tokenAddress).safeTransfer(
            creator,
            totalNumberOfTokens - totalTokensSold
        );
        emit WithdrewUnsoldTokens(msg.sender, amount);
    }
}


