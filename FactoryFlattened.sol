// Sources flattened with hardhat v2.22.8 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @openzeppelin/contracts/proxy/Clones.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/Clones.sol)

pragma solidity ^0.8.20;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 */
library Clones {
    /**
     * @dev A clone instance deployment failed.
     */
    error ERC1167FailedCreateClone();

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        if (instance == address(0)) {
            revert ERC1167FailedCreateClone();
        }
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        if (instance == address(0)) {
            revert ERC1167FailedCreateClone();
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// File contracts/dataStructures/UserDefinedTypes.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;



library UserDefinedTypes {

    enum PricingLogic {
        LinearFunction,
        QuadraticFunction,
        PolynomialFunction
    }

    struct AuctionCreationParams {
        address tokenAddress;
        uint256 numberOfTokens;
        uint256 startingPrice;
        address acceptedStable;
        address creator;
        uint256 auctionStartTime;
        uint256 auctionEndTime;
        PricingLogic logic;
    }


    string internal constant INVALID_RANGE = "Invalid range";
    string internal constant TRANSACTION_FAILED = "Transaction failed!";
    string internal constant INSUFFICIENT_TOKEN_BALANCE = "Insufficient Token balance";
    string internal constant BAD_AMOUNT = "You can't buy zero tokens";
    string internal constant ACCESS_FORBIDDEN = "Access Forbidden";

}


// File contracts/interfaces/ISingleAuction.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface ISingleAuction {
    function initialize(
        UserDefinedTypes.AuctionCreationParams memory _params
    ) external;

    function amountDueForPurchase(
        uint256 unitsOfTokensToBuy
    ) external view returns (uint256);

    function buyTokens(uint256 unitsOfTokensToBuy) external payable;

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external;

    //TO DO: Add Access control
    function withdrawRemainingBaseToken() external;

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external;
}


// File contracts/AuctionFactory.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;



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
