// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./data_structures/UserDefinedTypes.sol";
import "./interfaces/ISingleAuction.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./internal_contracts/ModelVerifier.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract AuctionFactory is Ownable, ModelVerifier {
    using Clones for address;
    using SafeERC20 for IERC20;

    address public masterAuctionEntryPoint;
    AuctionCreationParams[] public auctionsCreated;

    constructor(address _masterAuctionEntryPoint) Ownable(msg.sender) {
        masterAuctionEntryPoint = _masterAuctionEntryPoint;
    }

    //TO DO
    function createAuction(
        AuctionCreationParams memory _params
    ) external returns (address) {
        //TO DO: Time validation
        address masterModel = masterAuctionEntryPoint.clone();
        ISingleAuction(masterModel).initialize(_params);
       auctionsCreated.push(_params);
        return masterModel;  
    }

    //Add guard
    function updateMasterModel(address _newMasterModel) external onlyOwner {
        // confirmContractFeatures(_newMasterModel);
        masterAuctionEntryPoint = _newMasterModel;
    }


    function getAllAuctionsCreated() external view returns(AuctionCreationParams[] memory) {
        // AuctionCreationParams[] memory arrInMemory = new AuctionCreationParams[](auctionsCreated.length);
        // arrInMemory = auctionsCreated;
        return auctionsCreated;
    }

    
}

