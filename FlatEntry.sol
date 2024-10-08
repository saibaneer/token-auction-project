// Sources flattened with hardhat v2.22.8 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/utils/Address.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.20;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}


// File @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol@v5.0.2

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.20;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Storage of the initializable contract.
     *
     * It's implemented on a custom ERC-7201 namespace to reduce the risk of storage collisions
     * when using with upgradeable contracts.
     *
     * @custom:storage-location erc7201:openzeppelin.storage.Initializable
     */
    struct InitializableStorage {
        /**
         * @dev Indicates that the contract has been initialized.
         */
        uint64 _initialized;
        /**
         * @dev Indicates that the contract is in the process of being initialized.
         */
        bool _initializing;
    }

    // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INITIALIZABLE_STORAGE = 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00;

    /**
     * @dev The contract is already initialized.
     */
    error InvalidInitialization();

    /**
     * @dev The contract is not initializing.
     */
    error NotInitializing();

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint64 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that in the context of a constructor an `initializer` may be invoked any
     * number of times. This behavior in the constructor can be useful during testing and is not expected to be used in
     * production.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        // Cache values to avoid duplicated sloads
        bool isTopLevelCall = !$._initializing;
        uint64 initialized = $._initialized;

        // Allowed calls:
        // - initialSetup: the contract is not in the initializing state and no previous version was
        //                 initialized
        // - construction: the contract is initialized at version 1 (no reininitialization) and the
        //                 current contract is just being deployed
        bool initialSetup = initialized == 0 && isTopLevelCall;
        bool construction = initialized == 1 && address(this).code.length == 0;

        if (!initialSetup && !construction) {
            revert InvalidInitialization();
        }
        $._initialized = 1;
        if (isTopLevelCall) {
            $._initializing = true;
        }
        _;
        if (isTopLevelCall) {
            $._initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: Setting the version to 2**64 - 1 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint64 version) {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing || $._initialized >= version) {
            revert InvalidInitialization();
        }
        $._initialized = version;
        $._initializing = true;
        _;
        $._initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        _checkInitializing();
        _;
    }

    /**
     * @dev Reverts if the contract is not in an initializing state. See {onlyInitializing}.
     */
    function _checkInitializing() internal view virtual {
        if (!_isInitializing()) {
            revert NotInitializing();
        }
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        // solhint-disable-next-line var-name-mixedcase
        InitializableStorage storage $ = _getInitializableStorage();

        if ($._initializing) {
            revert InvalidInitialization();
        }
        if ($._initialized != type(uint64).max) {
            $._initialized = type(uint64).max;
            emit Initialized(type(uint64).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint64) {
        return _getInitializableStorage()._initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _getInitializableStorage()._initializing;
    }

    /**
     * @dev Returns a pointer to the storage namespace.
     */
    // solhint-disable-next-line var-name-mixedcase
    function _getInitializableStorage() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := INITIALIZABLE_STORAGE
        }
    }
}


// File contracts/data_structures/UserDefinedTypes.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;

enum PricingLogic {
        LinearFunction,
        QuadraticFunction,
        PolynomialFunction
    }

struct AuctionCreationParams {
        uint256 chargePerUnitTokenInEth;
        address tokenAddress;
        uint256 numberOfTokens;
        uint256 startingPrice;
        address acceptedStable;
        address creator;
        uint256 auctionStartTime;
        uint256 auctionEndTime;
        PricingLogic logic;
    }

struct FundAuctionParams {
    address tokenAddress;
    uint256 numberOfTokens;
}

library Errors {

    string internal constant INVALID_RANGE = "Invalid range";
    string internal constant TRANSACTION_FAILED = "Transaction failed!";
    string internal constant INSUFFICIENT_TOKEN_BALANCE = "Insufficient Token balance";
    string internal constant BAD_AMOUNT = "You can't buy zero tokens";
    string internal constant ACCESS_FORBIDDEN = "Access Forbidden";
    string internal constant SET_CHARGE_PER_UNIT_TOKEN = "Set charge per unit token!";
    string internal constant NO_TOKENS_TO_CLAIM = "You have no tokens to claim!";
    string internal constant CLAIM_AFTER_AUCTION = "Claim is possible after auction is expired";
    string internal constant AUCTION_IS_YET_TO_BEGIN = "Auction is yet to begin!";
    string internal constant AUCTION_HAS_ENDED = "Auction has ended!";
    string internal constant INSUFFICIENT_TOKEN_BALANCE_IN_CONTRACT = "Insufficient Token balance in contract";
    string internal constant ADDRESS_ZERO_NOT_ALLOWED = "Zero address not allowed!";
    string internal constant ZERO_AMOUNT_NOT_ALLOWED = "Zero amount not allowed";

}


// File contracts/interfaces/ISingleAuction.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface ISingleAuction {

    event BoughtTokens(address indexed caller, uint256 tokensBought, uint256 amountPaid);
    event BoughtTokensWithStableCoin(address indexed caller, uint256 tokensBought, uint256 amountPaid, address paymentCurrency);
    event WithdrewBaseTokens(address indexed caller, uint256 amount);
    event WithdrewUnsoldTokens(address indexed caller, uint256 amount);
    event ClaimedPurchasedTokens(address indexed caller, uint256 tokensClaimed, address tokenAddress);
    event SetSlope(uint256 indexed slope);

    function initialize(
        AuctionCreationParams memory _params
    ) external;

    function amountDueForPurchase(
        uint256 unitsOfTokensToBuy
    ) external view returns (uint256);

    // function buyTokens(uint256 unitsOfTokensToBuy) external payable;

    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external;

    //TO DO: Add Access control
    // function withdrawRemainingBaseToken() external;

    //TO DO: Add Access control
    function withdrawUnsoldTokens() external;
}


// File contracts/libraries/LinearPricingLogicLibrary.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title LinearPricingLogicLib
/// @notice Provides functions to calculate prices based on a linear pricing curve.
/// @dev This library is used to implement linear pricing in an auction or token sale.
library LinearPricingLogicLib {

    /// @notice Calculates the average price for purchasing a specified number of tokens using a linear pricing curve.
    /// @dev The function assumes that prices increase linearly with each additional token sold.
    ///      The calculation is based on the formula for the sum of an arithmetic series:
    ///      Total Cost = (Number of Tokens) * (Average Price)
    ///      Average Price = (First Token Price + Last Token Price) / 2
    ///      First Token Price = startingBidPrice + (chargePerUnitToken * totalTokensSold)
    ///      Last Token Price = First Token Price + ((unitOfTokensToBuy - 1) * chargePerUnitToken)
    /// @param unitOfTokensToBuy The number of tokens that the user intends to buy.
    /// @param chargePerUnitToken The price increment for each additional token.
    /// @param startingBidPrice The starting price of the first token.
    /// @param totalTokensSold The total number of tokens sold before this purchase.
    /// @return The total cost for the specified number of tokens.
    function getAverageLinearPrice(
        uint256 unitOfTokensToBuy,
        uint256 chargePerUnitToken,
        uint256 startingBidPrice,
        uint256 totalTokensSold
    ) internal pure returns (uint256) {

        // Calculate the price of the first token in this purchase based on the starting price and the number of tokens sold so far.
        uint256 currentPrice = startingBidPrice + (chargePerUnitToken * totalTokensSold);
        
        // Calculate the price of the last token in this purchase.
        // The last token price is the price of the first token in this purchase plus (unitsOfTokensToBuy - 1) * chargePerUnitToken.
        uint256 priceOfNextToken = currentPrice + ((unitOfTokensToBuy - 1) * chargePerUnitToken);
        
        // The total cost is derived from the formula for the sum of an arithmetic series:
        // Total Cost = (Number of Tokens) * (First Token Price + Last Token Price) / 2
        // This formula calculates the total cost by multiplying the number of tokens by the average price of the first and last tokens.
        return unitOfTokensToBuy * (priceOfNextToken + currentPrice) / 2;
    }
}


// File contracts/libraries/QuadraticPricingLogicLibrary.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title QuadraticPricingLogicLib
/// @notice Provides functions to calculate prices based on a quadratic pricing curve.
/// @dev This library is used to implement quadratic pricing in an auction or token sale.
library QuadraticPricingLogicLib {

    /// @notice Calculates the price of the nth token using a quadratic bonding curve.
    /// @dev The price increases quadratically with each subsequent token.
    ///      The formula used is: Price(n) = initialPrice + priceMultiplier * (n^2)
    ///      where n is the position of the token in the sequence.
    /// @param n The position of the token in the sequence (starting from 1).
    /// @param initialPrice The initial price of the first token.
    /// @param priceMultiplier The multiplier that affects how quickly the price increases.
    /// @return The price of the nth token.
    function getPriceOfNthToken(
        uint256 n,
        uint256 initialPrice,
        uint256 priceMultiplier
    ) internal pure returns (uint256) {
        return initialPrice + (priceMultiplier * (n ** 2));
    }

    /// @notice Calculates the sum of squares for a range of integers from n to m.
    /// @dev This function uses the mathematical formula for the sum of squares:
    ///      Sum of squares = (m * (m + 1) * (2m + 1)) / 6
    ///      This is applied to both m and n, and the result is the difference between the two.
    ///      The sum of squares formula is used to calculate the total cost in a quadratic pricing model.
    /// @param n The starting integer (exclusive).
    /// @param m The ending integer (inclusive).
    /// @return The sum of squares from (n+1) to m.
    function sumOfSquares(uint256 n, uint256 m) internal pure returns (uint256) {
        uint256 sumM = (m * (m + 1) * (2 * m + 1)) / 6;
        uint256 sumN = (n * (n + 1) * (2 * n + 1)) / 6;
        return sumM - sumN;
    }

    /// @notice Calculates the total price for purchasing a given amount of tokens using a quadratic pricing curve.
    /// @dev This function avoids the use of loops by leveraging the sum of squares formula.
    ///      The total cost is calculated as:
    ///      Total Cost = amount * startingBidPrice + priceMultiplier * sumOfSquares(n, m)
    ///      where n is the number of tokens sold before this purchase and m is the total number of tokens after the purchase.
    /// @param amount The number of tokens to purchase.
    /// @param totalTokensSold The total number of tokens sold before this purchase.
    /// @param startingBidPrice The starting price for each token.
    /// @param priceMultiplier The multiplier affecting how the price increases with each token.
    /// @return The total cost for purchasing the specified number of tokens.
    function calculateTotalPrice(
        uint256 amount,
        uint256 totalTokensSold,
        uint256 startingBidPrice,
        uint256 priceMultiplier
    ) internal pure returns (uint256) {
        uint256 n = totalTokensSold; // The number of tokens sold before this purchase.
        uint256 m = n + amount; // The total number of tokens after this purchase.

        // Calculate the sum of squares for the range from n+1 to m
        uint256 sumSquares = sumOfSquares(n, m);

        // The total price is calculated as the sum of the starting price for all tokens plus the sum of the quadratic increases.
        uint256 totalPrice = amount * startingBidPrice + priceMultiplier * sumSquares;

        return totalPrice;
    }
}


// File contracts/Storage.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;



contract Storage {
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalPrice);

    uint256 public totalNumberOfTokens;
    uint256 public totalTokensSold;
    uint256 public chargePerUnitToken; 
    uint256 public startingBidPrice; 
    address public acceptableStableCoin;
    address public tokenAddress;
    address public creator;
    uint256 public auctionStartTime;
    uint256 public auctionEndTime;
    uint8 public modelType;

    

    mapping(address => uint256) public balances;

}


// File contracts/internal_contracts/InternalAuctionFunctions.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;







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

        // Optional: Uncomment to check that the auction start time is in the future
        require(_params.auctionStartTime > block.timestamp, "Auction start time must be in the future");

        // Optional: Uncomment to check that the auction end time is after the start time
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


    /// @notice Allows a user to purchase tokens using Ether
    /// @param unitsOfTokensToBuy The number of tokens the user wants to purchase
    /// @param _caller The address of the user purchasing the tokens
    /// @dev Calculates the total price based on the linear or quadratic pricing model and transfers the Ether to the contract
    function _buyTokens(uint256 unitsOfTokensToBuy, address _caller) internal {
        require(
            IERC20(tokenAddress).balanceOf(address(this)) > 0,
            Errors.INSUFFICIENT_TOKEN_BALANCE_IN_CONTRACT
        );
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

        require(msg.value >= purchasePrice, Errors.INSUFFICIENT_TOKEN_BALANCE);

        balances[_caller] += unitsOfTokensToBuy;
        totalTokensSold += unitsOfTokensToBuy;
        uint256 amount = msg.value;

        // Transfer the received Ether to the contract
        (bool success, ) = address(this).call{value: amount}("");
        require(success, Errors.TRANSACTION_FAILED);
        emit BoughtTokens(_caller, unitsOfTokensToBuy, amount);
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


// File contracts/AuctionEntrypoint.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.24;

/// @title AuctionEntrypoint
/// @notice Provides the entry points for external interaction with the auction system.
contract AuctionEntrypoint is InternalAuction {

    /// @notice Initializes the auction with the provided parameters.
    /// @dev Calls the internal `_initialize` function to set up the auction parameters.
    /// @param _params Struct containing all necessary parameters for auction creation.
    function initialize(
        AuctionCreationParams memory _params
    ) external {
        _initialize(_params);
    }

    /// @notice Allows the auction creator to fund the auction by transferring the specified tokens to the contract.
    /// @dev The function uses the `msg.sender` to identify the caller and pass it to the internal `_fundAuction` function.
    function fundAuction() external {
        _fundAuction(msg.sender);
    }


    /// @notice Calculates the total cost for purchasing a specified number of tokens.
    /// @param unitsOfTokensToBuy The number of tokens the buyer wants to purchase.
    /// @return The total cost in the base currency (ETH or stablecoin) for the specified number of tokens.
    function amountDueForPurchase(
        uint256 unitsOfTokensToBuy
    ) external view returns (uint256) {
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
        return purchasePrice;
    }

    /// @notice Allows a user to purchase tokens using a stablecoin.
    /// @dev The function uses the `msg.sender` to identify the caller and pass it to the internal `_buyTokensWithStableCoin` function.
    /// @param unitsOfTokensToBuy The number of tokens the buyer wants to purchase.
    function buyTokensWithStableCoin(uint256 unitsOfTokensToBuy) external {
        _buyTokensWithStableCoin(unitsOfTokensToBuy, msg.sender);
    }

    /// @notice Allows a user to claim their purchased tokens after the auction has ended.
    /// @dev The function calls the internal `_claimPurchasedTokens` function, passing the `msg.sender` as the caller.
    function claimPurchasedTokens() external {
        _claimPurchasedTokens(msg.sender);
    }

    /// @notice Allows the auction creator to withdraw any unsold tokens after the auction ends.
    /// @dev Access control should be added to restrict this function to the auction creator only.
    /// TO DO: Implement access control.
    function withdrawUnsoldTokens() external {
        _withdrawUnsoldTokens();
    }

    /// @notice Returns the amount of time left until the auction ends.
    /// @dev If the auction has already ended, the function returns 0.
    /// @return The number of seconds remaining until the auction ends.
    function timeLeftInAuction() external view returns(uint256) {
        return block.timestamp < auctionEndTime ? auctionEndTime - block.timestamp : 0;
    }
}
