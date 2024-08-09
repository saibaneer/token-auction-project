// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./dataStructures/UserDefinedTypes.sol";
import "./interfaces/ISingleAuction.sol";
contract AuctionFactory {
    using Clones for address;

    mapping (UserDefinedTypes.PricingLogic => address) public preferredPricingLogic;
    address public linearPricingModel;
    address public quadraticPricingModel;
    address public polynomialPricingModel;

    constructor() {

    }

    //TO DO
    function createAuction(
        UserDefinedTypes.AuctionCreationParams memory _params
    ) external returns (address) {
        address model = (preferredPricingLogic[_params.logic]).clone();
        ISingleAuction(model).initialize(_params);
        return model;  
    }

    //TO DO: Add guard
    function updatePricingModel(UserDefinedTypes.PricingLogic _logic, address _model) public {
        preferredPricingLogic[_logic] = _model;
    }
}

// Didnt use a library because once in production you can't change logic, but external contract allows for it
