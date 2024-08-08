// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./SharedStorage.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./libraries/LinearPricingLogicLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LinearAuction is Initializable, SharedStorage {
    using SafeERC20 for IERC20;

    modifier onlyCreator() {
        require(msg.sender == creator, "Access Forbidden");
            _;
        
    }

    function initialize(
        address _tokenAddress,
        uint256 _totalNumberOfTokens,
        uint256 _totalTokensSold,
        uint256 _chargePerUnitToken,
        uint256 _startingBidPrice,
        address _acceptableStableCoin,
        address _creator
    ) public initializer {
        totalNumberOfTokens = _totalNumberOfTokens;
        totalTokensSold = _totalTokensSold;
        chargePerUnitToken = _chargePerUnitToken;
        startingBidPrice = _startingBidPrice;
        acceptableStableCoin = _acceptableStableCoin;
        tokenAddress = _tokenAddress;
        creator = _creator;
    }

    function amountDueForPurchase(uint256 unitsOfTokensToBuy) external view returns(uint256) {
        return LinearPricingLogicLib.getAverageLinearPrice(unitsOfTokensToBuy, chargePerUnitToken, startingBidPrice, totalTokensSold);
    }
    function buyTokens(uint256 unitsOfTokensToBuy) external payable {
        require(unitsOfTokensToBuy > 0, "You can't buy zero tokens");
        require(totalTokensSold + unitsOfTokensToBuy <= totalNumberOfTokens);
        uint256 purchasePrice = LinearPricingLogicLib.getAverageLinearPrice(unitsOfTokensToBuy, chargePerUnitToken, startingBidPrice, totalTokensSold);
        
        require(msg.value >= purchasePrice, "Insufficient funds!");

        balances[msg.sender] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        totalNumberOfTokens -= unitsOfTokensToBuy;

        //pay via base token
        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, "Payment failed!");
        
    }

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external {
        require(unitsOfTokensToBuy > 0, "You can't buy zero tokens");
        require(totalTokensSold + unitsOfTokensToBuy <= totalNumberOfTokens);
        
        uint256 purchasePrice = LinearPricingLogicLib.getAverageLinearPrice(unitsOfTokensToBuy, chargePerUnitToken, startingBidPrice, totalTokensSold);
        require(IERC20(acceptableStableCoin).balanceOf(msg.sender) > purchasePrice, "Insufficient Token balance");
     

        balances[msg.sender] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        totalNumberOfTokens -= unitsOfTokensToBuy;

        IERC20(acceptableStableCoin).safeTransferFrom(msg.sender, address(this), purchasePrice);
        

    }

    //TO DO: Add Access control
    function withdrawRemainingBaseToken() external onlyCreator {
        (bool success, ) = payable(creator).call{value: address(this).balance}("");
        require(success, "Transaction failed!");
    }

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external onlyCreator {
        IERC20(tokenAddress).safeTransfer(creator, totalNumberOfTokens - totalTokensSold);
    }
}



