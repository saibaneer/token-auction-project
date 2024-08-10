// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./data_structures/UserDefinedTypes.sol";
import "./interfaces/ISingleAuction.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./internal_contracts/ModelVerifier.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title AuctionFactory
/// @notice This contract is responsible for creating and managing auctions based on a master contract model.
/// @dev Uses the Clones library to deploy minimal proxy contracts for auctions.
contract AuctionFactory is Ownable, ModelVerifier {
    using Clones for address;
    using SafeERC20 for IERC20;

    /// @notice The address of the master auction entry point contract.
    /// @dev This contract is cloned to create new auction instances.
    address public masterAuctionEntryPoint;

    /// @notice An array to keep track of all the auctions created by this factory.
    AuctionCreationParams[] public auctionsCreated;

    /// @notice Constructor to initialize the factory with the master auction contract.
    /// @param _masterAuctionEntryPoint The address of the master auction contract used for cloning.
    constructor(address _masterAuctionEntryPoint) Ownable(msg.sender) {
        masterAuctionEntryPoint = _masterAuctionEntryPoint;
    }

    /// @notice Creates a new auction by cloning the master auction contract.
    /// @param _params A struct containing all necessary parameters for creating the auction.
    /// @return The address of the newly created auction contract.
    /// @dev The function uses the Clones library to clone the master auction contract.
    function createAuction(
        AuctionCreationParams memory _params
    ) external returns (address) {
        // TODO: Add time validation to ensure auction parameters are valid.
        
        // Clone the master auction contract to create a new auction instance.
        address masterModel = masterAuctionEntryPoint.clone();

        // Initialize the new auction instance with the provided parameters.
        ISingleAuction(masterModel).initialize(_params);

        // Store the auction creation parameters in the array.
        auctionsCreated.push(_params);

        // Return the address of the newly created auction contract.
        return masterModel;  
    }

    /// @notice Updates the master auction model used for cloning.
    /// @param _newMasterModel The address of the new master auction model contract.
    /// @dev This function is restricted to the contract owner and could include a feature confirmation step.
    function updateMasterModel(address _newMasterModel) external onlyOwner {
        // TODO: Uncomment and implement confirmContractFeatures(_newMasterModel) to ensure the new model meets required standards.
        
        // Update the master auction entry point to the new model address.
        masterAuctionEntryPoint = _newMasterModel;
    }

    /// @notice Retrieves all auctions created by this factory.
    /// @return An array of AuctionCreationParams structs representing the auctions created.
    function getAllAuctionsCreated() external view returns(AuctionCreationParams[] memory) {
        // Return the array of auctions created.
        return auctionsCreated;
    }
}