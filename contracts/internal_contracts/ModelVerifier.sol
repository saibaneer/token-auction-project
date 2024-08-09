// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

abstract contract ModelVerifier {
    bytes4 public constant initializeSelector =
        bytes4(
            keccak256(
                "initialize((address,uint256,uint256,address,address,uint256,uint256,PricingLogic))"
            )
        );
    bytes4 public constant setSlopeSelector =
        bytes4(keccak256("setSlope(uint256"));
    bytes4 public constant buyTokensSelector =
        bytes4(keccak256("buyTokens(uint256)"));
    bytes4 public constant buyTokensWithStableCoinSelector =
        bytes4(keccak256("buyTokensWithStableCoin(uint256)"));
    bytes4 public constant withdrawRemainingBaseTokenSelector =
        bytes4(keccak256("withdrawRemainingBaseToken()"));
    bytes4 public constant withdrawUnsoldTokenSelector =
        bytes4(keccak256("withdrawUnsoldTokens()"));
    
    bytes4 public constant claimPurchasedTokensSelector = bytes4(keccak256("claimPurchasedTokens()"));

    function hasExpectedFeatures(
        address _contract,
        bytes4 _selector
    ) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_contract)
        }
        if (size == 0) {
            return false; // Not a contract
        }

        (bool success, ) = _contract.staticcall(
            abi.encodeWithSelector(_selector)
        );

        return success;
    }

    function confirmContractFeatures(
        address _contract
    ) internal view returns (bool) {
        require(hasExpectedFeatures(_contract, initializeSelector), "Lacks initialize feature");
        require(hasExpectedFeatures(_contract, setSlopeSelector), "Lacks set slope feature");
        require(hasExpectedFeatures(_contract, buyTokensSelector), "Lacks buy tokens with base token feature");
        require(hasExpectedFeatures(_contract, buyTokensWithStableCoinSelector), "Lacks buy tokens with token feature");
        require(hasExpectedFeatures(_contract, withdrawRemainingBaseTokenSelector), "Lacks ability to withdraw base tokens");
        require(hasExpectedFeatures(_contract, withdrawUnsoldTokenSelector), "Lacks ability to withdraw unsold tokens");
        require(hasExpectedFeatures(_contract, claimPurchasedTokensSelector), "Lacks claim tokens feature");
        
        return true;

        
    }
}
