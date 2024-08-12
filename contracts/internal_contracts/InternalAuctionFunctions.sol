// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../libraries/LinearPricingLogicLibrary.sol";
import "../libraries/QuadraticPricingLogicLibrary.sol";
import "../interfaces/ISingleAuction.sol";
import {AuctionCreationParams, PricingLogic} from "../data_structures/UserDefinedTypes.sol";
import "../Storage.sol";

/// @title InternalAuction
/// @notice Provides internal functions for managing auction operations.
/// @dev This contract is abstract and intended to be inherited by other contracts.
abstract contract InternalAuction is ISingleAuction, Initializable, Storage {
    using SafeERC20 for IERC20;

    /// @notice Ensures that only the auction creator can call certain functions
    modifier onlyCreator() {
        require(msg.sender == creator, Errors.ACCESS_FORBIDDEN);
        _;
    }

    /// @notice Initializes the auction with the provided parameters.
    /// @dev This function performs validation checks on the provided parameters to ensure they are valid.
    ///      It then initializes the auction state variables with these parameters.
    /// @param _params A struct containing the auction creation parameters.
    ///        - tokenAddress: The address of the ERC20 token being auctioned. Must not be the zero address.
    ///        - numberOfTokens: The total number of tokens available for auction. Must be greater than zero.
    ///        - startingPrice: The starting price for the auction. Must be greater than zero.
    ///        - acceptedStable: The address of the stablecoin accepted for payment. Must not be the zero address.
    ///        - creator: The address of the auction creator. Must not be the zero address.
    ///        - auctionStartTime: The timestamp when the auction is set to start. Must be in the future (currently commented out).
    ///        - auctionEndTime: The timestamp when the auction is set to end. Must be after the start time (currently commented out).
    ///        - logic: The pricing logic to be used in the auction (e.g., linear or quadratic).
    function _initialize(
        AuctionCreationParams memory _params
    ) internal initializer {
        // Check that the token address is valid
        require(
            _params.tokenAddress != address(0),
            Errors.ADDRESS_ZERO_NOT_ALLOWED
        );

        // Check that the number of tokens is greater than zero
        require(_params.numberOfTokens > 0, Errors.ZERO_AMOUNT_NOT_ALLOWED);

        // Check that the starting price is greater than zero
        require(_params.startingPrice > 0, Errors.ZERO_AMOUNT_NOT_ALLOWED);

        // Check that the accepted stablecoin address is valid
        require(
            _params.acceptedStable != address(0),
            Errors.ADDRESS_ZERO_NOT_ALLOWED
        );

        // Check that the creator address is valid
        require(_params.creator != address(0), Errors.ADDRESS_ZERO_NOT_ALLOWED);

        require(_params.chargePerUnitTokenInEth < 1 ether || _params.chargePerUnitTokenInEth > 0.01 ether, Errors.INVALID_RANGE);

        require(_params.auctionStartTime > block.timestamp, "Auction start time must be in the future");

        require(_params.auctionEndTime > _params.auctionStartTime, "Auction end time must be after start time");

        // Initialize state variables with the provided parameters
        totalNumberOfTokens = _params.numberOfTokens;
        startingBidPrice = _params.startingPrice;
        acceptableStableCoin = _params.acceptedStable;
        tokenAddress = _params.tokenAddress;
        creator = _params.creator;
        auctionStartTime = _params.auctionStartTime;
        auctionEndTime = _params.auctionEndTime;
        modelType = uint8(_params.logic);
        chargePerUnitToken = _params.chargePerUnitTokenInEth;
    }

    /// @notice Allows the creator to fund the auction with tokens
    /// @param _caller Address of the creator funding the auction
    /// @dev Transfers the total number of tokens from the creator to the contract
    function _fundAuction(address _caller) internal onlyCreator {
        require(
            IERC20(tokenAddress).balanceOf(_caller) >= totalNumberOfTokens,
            Errors.INSUFFICIENT_TOKEN_BALANCE
        );
        IERC20(tokenAddress).safeTransferFrom(
            _caller,
            address(this),
            totalNumberOfTokens
        );
    }


    /// @notice Allows a user to purchase tokens using a stablecoin
    /// @param unitsOfTokensToBuy The number of tokens the user wants to purchase
    /// @param _caller The address of the user purchasing the tokens
    /// @dev Transfers the stablecoin from the user to the contract and updates balances
    function _buyTokensWithStableCoin(
        uint256 unitsOfTokensToBuy,
        address _caller
    ) internal {
        require(chargePerUnitToken != 0, Errors.SET_CHARGE_PER_UNIT_TOKEN);
        require(unitsOfTokensToBuy > 0, Errors.BAD_AMOUNT);
        require(
            (totalTokensSold + unitsOfTokensToBuy) * 10 ** 18 <=
                totalNumberOfTokens
        );
        require(
            block.timestamp >= auctionStartTime,
            Errors.AUCTION_IS_YET_TO_BEGIN
        );
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

        balances[_caller] += unitsOfTokensToBuy * 10 ** 18;
        totalTokensSold += unitsOfTokensToBuy;

        IERC20(acceptableStableCoin).safeTransferFrom(
            _caller,
            address(this),
            purchasePrice
        );
        emit BoughtTokensWithStableCoin(
            _caller,
            unitsOfTokensToBuy,
            purchasePrice,
            acceptableStableCoin
        );
    }

    /// @notice Allows a user to claim purchased tokens after the auction ends
    /// @param _caller The address of the user claiming the tokens
    /// @dev Transfers the tokens to the user and resets their balance in the contract
    function _claimPurchasedTokens(address _caller) internal {
        uint256 amountDue = balances[_caller];
        require(amountDue > 0, Errors.NO_TOKENS_TO_CLAIM);
        require(block.timestamp >= auctionEndTime, Errors.CLAIM_AFTER_AUCTION);

        balances[_caller] = 0;
        IERC20(tokenAddress).safeTransfer(_caller, amountDue);
        emit ClaimedPurchasedTokens(_caller, amountDue, tokenAddress);
    }

    /// @notice Allows the creator to withdraw remaining Ether after the auction ends
    /// @dev Transfers the contract's balance to the creator
    function _withdrawRemainingBaseToken() internal onlyCreator {
        uint amount = address(this).balance;
        (bool success, ) = payable(creator).call{value: amount}("");
        require(success, Errors.TRANSACTION_FAILED);
        emit WithdrewBaseTokens(msg.sender, amount);
    }

    /// @notice Allows the creator to withdraw unsold tokens after the auction ends
    /// @dev Transfers the remaining unsold tokens to the creator
    function _withdrawUnsoldTokens() internal onlyCreator {
        uint256 amount = totalNumberOfTokens - (totalTokensSold * 10 ** 18);
        IERC20(tokenAddress).safeTransfer(creator, amount);
        emit WithdrewUnsoldTokens(msg.sender, amount);
    }
}
