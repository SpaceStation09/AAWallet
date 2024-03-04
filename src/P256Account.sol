// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "p256-verifier/src/P256.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

import "./basic/BaseAccount.sol";
import "./utils/TokenCallbackHandler.sol";
import "./interfaces/UserOperation.sol";

/**
 * p256 signature account
 *  this is a sample minimal p256-signature account
 *  has basic execute, eth handling methods
 *  a single secp256r1 keypair as the owner.
 */

contract P256Account is BaseAccount, Initializable, TokenCallbackHandler  {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using UserOperationLib for UserOperation;

    address public owner;
    uint256[2] public p256Owner;
    IEntryPoint private immutable _entryPoint;

    event P256AccountInitialized(IEntryPoint indexed entryPoint, address indexed owner);

    modifier onlyOwner(){
        _onlyOwner();
        _;
    }
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    constructor(IEntryPoint anEntryPoint) {
        _entryPoint = anEntryPoint;
        _disableInitializers();
    }

    /**
     * @dev The _entryPoint member is bond with the implementation of P256Account (immutable).
     * To upgrade EntryPoint address, a new implementation contract should be deployed and then
     * upgrading the implementation by calling `upgradeTo()` 
     */    
    function initialize(address _owner) public virtual initializer {
        _initialize(_owner);
    }

    /// @inheritdoc BaseAccount
    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }

    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external {
        _requireFromEntryPointOrOwner();
        _call(dest, value, func);
    }

    /**
     * execute a sequence of transactions
     */
    function executeBatch(address[] calldata dest, bytes[] calldata func) external {
        _requireFromEntryPointOrOwner();
        require(dest.length == func.length, "wrong array lengths");
        for (uint256 i = 0; i < dest.length; i++) {
            _call(dest[i], 0, func[i]);
        }
    }


    /**
     * check current account deposit in the entryPoint
     */
    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    /**
     * deposit more funds for this account in the entryPoint
     */
    function addDeposit() public payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    /**
     * withdraw deposit from entryPoint
     * @param _recipient the target address to receive deposit
     * @param _amount to withdraw
     */
    function withdrawDepositTo(address payable _recipient, uint256 _amount) public onlyOwner {
        entryPoint().withdrawTo(_recipient, _amount);
    }

    function _initialize(address _owner) internal virtual {
        owner = _owner; 
        emit P256AccountInitialized(_entryPoint, _owner);
    }

    function _onlyOwner() internal view {
        // require the caller to be the secp256k1 keypair or the account itself.
        require(msg.sender == owner || msg.sender == address(this), "only owner");

    }

    function _requireFromEntryPointOrOwner() internal view{
        require(msg.sender == address(entryPoint()) || msg.sender == owner, "Account: not owner or EntryPoint");
    }

    function _validateSignature(UserOperation calldata userOp, bytes32 userOpHash) internal virtual override returns (uint256 validationData) {
        if(userOp.signature.length == 65){
            bytes32 hash = userOpHash.toEthSignedMessageHash();
            if (owner != hash.recover(userOp.signature)) return SIG_VALIDATION_FAILED;
        }else {
            (uint256 r, uint256 s) = abi.decode(userOp.signature, (uint256, uint256));
            bytes32 userOpSHA256 = _getUserOpSHA256(userOp);
            if(!P256.verifySignatureAllowMalleability(userOpSHA256, r, s, p256Owner[0], p256Owner[1])) return SIG_VALIDATION_FAILED;
        }
    }

    function _call(
        address target,
        uint256 value,
        bytes memory data
    ) internal {
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function _getUserOpSHA256(UserOperation calldata userOp) internal pure returns(bytes32){
        return sha256(abi.encode(userOp.hash(), address(0), 0));
    }
}