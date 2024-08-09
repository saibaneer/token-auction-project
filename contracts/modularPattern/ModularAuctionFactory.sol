// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "../data_structures/UserDefinedTypes.sol";
import "../interfaces/ISingleAuction.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../internal_contracts/ModelVerifier.sol";
contract ModularAuctionFactory is ModelVerifier {
    using Clones for address;
    using SafeERC20 for IERC20;

    mapping (PricingLogic => address) public preferredPricingLogic;
    address public linearPricingModel;
    address public quadraticPricingModel;
    address public polynomialPricingModel;

    AuctionCreationParams[] public auctionsCreated;

    //TO DO
    function createAuction(
        AuctionCreationParams memory _params
    ) external returns (address) {
        address model = (preferredPricingLogic[_params.logic]).clone();
        ISingleAuction(model).initialize(_params);
        require(IERC20(_params.tokenAddress).balanceOf(msg.sender) >= _params.numberOfTokens);
        IERC20(_params.tokenAddress).safeTransferFrom(msg.sender, model, _params.numberOfTokens);
        auctionsCreated.push(_params);
        return model;  
    }

    //TO DO: Add guard
    function updatePricingModel(PricingLogic _logic, address _model) public {
        confirmContractFeatures(_model);
        preferredPricingLogic[_logic] = _model;
    }

    function getAllAuctionsCreated() external view returns(AuctionCreationParams[] memory) {
        // AuctionCreationParams[] memory arrInMemory = new AuctionCreationParams[](auctionsCreated.length);
        // arrInMemory = auctionsCreated;
        return auctionsCreated;
    }

    
}

