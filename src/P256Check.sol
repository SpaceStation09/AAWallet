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

    function getUserOpHash(UserOperation calldata userOp) public pure returns (bytes32){
        return sha256(abi.encode(getUserOpSHA256(userOp), address(0), 0));
    }

    function getUserOpSHA256(UserOperation calldata userOp) public pure returns (bytes32){
        return sha256(pack(userOp));
    }

    function pack(UserOperation calldata userOp) internal pure returns (bytes memory ret) {
        address sender = getSender(userOp);
        uint256 nonce = userOp.nonce;
        bytes32 hashInitCode = sha256(userOp.initCode);
        bytes32 hashCallData = sha256(userOp.callData);
        uint256 callGasLimit = userOp.callGasLimit;
        uint256 verificationGasLimit = userOp.verificationGasLimit;
        uint256 preVerificationGas = userOp.preVerificationGas;
        uint256 maxFeePerGas = userOp.maxFeePerGas;
        uint256 maxPriorityFeePerGas = userOp.maxPriorityFeePerGas;
        bytes32 hashPaymasterAndData = sha256(userOp.paymasterAndData);

        return
            abi.encode(
                sender,
                nonce,
                hashInitCode,
                hashCallData,
                callGasLimit,
                verificationGasLimit,
                preVerificationGas,
                maxFeePerGas,
                maxPriorityFeePerGas,
                hashPaymasterAndData
            );
    }

    function getSender(UserOperation calldata userOp) internal pure returns (address) {
        address data;
        //read sender from userOp, which is first userOp member (saves 800 gas...)
        assembly {
            data := calldataload(userOp)
        }
        return address(uint160(data));
    }
}