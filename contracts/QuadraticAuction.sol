// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./SharedStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./libraries/QuadraticPricingLogicLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ISingleAuction.sol";
import "./dataStructures/UserDefinedTypes.sol";

contract QuadraticAuction is ISingleAuction, Initializable, SharedStorage {
    using SafeERC20 for IERC20;

    modifier onlyCreator() {
        require(msg.sender == creator, UserDefinedTypes.ACCESS_FORBIDDEN);
        _;
    }

    function initialize(
        UserDefinedTypes.AuctionCreationParams memory _params
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
        require(_m < 1 ether || _m > 0.01 ether, UserDefinedTypes.INVALID_RANGE);
        chargePerUnitToken = _m;
    }

    function amountDueForPurchase(
        uint256 _unitsOfTokensToBuy
    ) external view returns (uint256) {
        return
            QuadraticPricingLogicLib.calculateTotalPrice(
                _unitsOfTokensToBuy,
                totalTokensSold,
                startingBidPrice,
                chargePerUnitToken
            );
    }

    function buyTokens(uint256 unitsOfTokensToBuy) external payable {
        require(unitsOfTokensToBuy > 0, UserDefinedTypes.BAD_AMOUNT);
        require(totalTokensSold + unitsOfTokensToBuy <= totalNumberOfTokens);
        uint256 purchasePrice = QuadraticPricingLogicLib.calculateTotalPrice(
                unitsOfTokensToBuy,
                totalTokensSold,
                startingBidPrice,
                chargePerUnitToken
            );

        require(
            msg.value >= purchasePrice,
            UserDefinedTypes.INSUFFICIENT_TOKEN_BALANCE
        );

        balances[msg.sender] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        totalNumberOfTokens -= unitsOfTokensToBuy;

        //pay via base token
        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, UserDefinedTypes.TRANSACTION_FAILED);
    }

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external {
        require(unitsOfTokensToBuy > 0, UserDefinedTypes.BAD_AMOUNT);
        require(totalTokensSold + unitsOfTokensToBuy <= totalNumberOfTokens);

        uint256 purchasePrice = QuadraticPricingLogicLib.calculateTotalPrice(
                unitsOfTokensToBuy,
                totalTokensSold,
                startingBidPrice,
                chargePerUnitToken
            );
        require(
            IERC20(acceptableStableCoin).balanceOf(msg.sender) > purchasePrice,
            UserDefinedTypes.INSUFFICIENT_TOKEN_BALANCE
        );

        balances[msg.sender] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        totalNumberOfTokens -= unitsOfTokensToBuy;

        IERC20(acceptableStableCoin).safeTransferFrom(
            msg.sender,
            address(this),
            purchasePrice
        );
    }

    //TO DO: Add Access control
    function withdrawRemainingBaseToken() external onlyCreator {
        (bool success, ) = payable(creator).call{value: address(this).balance}(
            ""
        );
        require(success, UserDefinedTypes.TRANSACTION_FAILED);
    }

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external onlyCreator {
        IERC20(tokenAddress).safeTransfer(
            creator,
            totalNumberOfTokens - totalTokensSold
        );
    }
}


