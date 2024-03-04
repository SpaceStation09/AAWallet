// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import "p256-verifier/src/P256.sol";
import "forge-std/console2.sol";
import "./interfaces/UserOperation.sol";

contract P256Check {
    using UserOperationLib for UserOperation;

    function check(bytes32 hash, uint256 r, uint256 s, uint256 x, uint256 y) view external returns(bool) {
        return P256.verifySignatureAllowMalleability(hash, r, s, x, y);
    }

    function checkPacked(bytes32 hash, bytes memory sig, uint256 x, uint256 y) view external returns(bool){
        (uint256 r, uint256 s) = splitSig(sig);
        return P256.verifySignatureAllowMalleability(hash, r, s, x, y);
    }

    function checkUserOp(UserOperation calldata userOp, bytes memory packedSig, uint256 x, uint y) view external returns(bool) {
        (uint256 r, uint256 s) = splitSig(packedSig);
        bytes32 userOpHash = getUserOpHash(userOp);
        return P256.verifySignatureAllowMalleability(userOpHash, r, s, x, y);
    }

    function splitSig(bytes memory packedSig) internal pure returns (uint256, uint256) {
        uint256 r;
        uint256 s;
        assembly {
            r := mload(add(add(packedSig, 0x20), 0))
            s := mload(add(add(packedSig, 0x20), 32))
        }
        return (r,s);
    }

    function getUserOpHash(UserOperation calldata userOp) internal pure returns (bytes32){
        return sha256(abi.encode(userOp.hash(), address(0), 0));
    }
}