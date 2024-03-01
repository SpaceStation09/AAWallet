// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "p256-verifier/src/P256.sol";
import "p256-verifier/src/P256Verifier.sol";
import "../src/P256Check.sol";
import "forge-std/console2.sol";
import "../src/interfaces/UserOperation.sol";
import {Test} from "forge-std/Test.sol";

contract P256CheckTest is Test {
    P256Check p256check;
    uint256[2] public pubKey;
    uint256[2] public userOpKey;
    bytes32 msgHash;
    bytes32 userOpHash;
    UserOperation userOp;
    
    function setUp() public {
        // Deploy P256 Verifier
        vm.etch(P256.VERIFIER, type(P256Verifier).runtimeCode);
        pubKey = [
            0x5fb05ad558c7113c12a712008b726360c4c2aca5448630cd3281b858f00e98ae,
            0x2d6ce14584f77bd5e696ee5e057c2d7af01ca785e3dc22d172aa486bb66e77d1
        ];
        userOpKey = [
            0xd5490f4f54669a9c0261ac3648568b4fd12d8783d3738e776749b57a41ec6780,
            0x888557b58ea3c6eb9258c2403a0f9e97c331113635dcca04ac011da070a15f9b
        ];
        msgHash = 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;
        userOpHash = 0xc741c4e3291f770a7b8e3d082346aa12fd575ee400885a8cdb81f5562d2a16e4;
        p256check = new P256Check();
    }

    function testP256() public {
        uint256 r = 0x8fb3ca2982598e182d1fe1b8508cdc07c8932e80ea7168b6b8cb361fbf90dae2;
        uint256 s = 0x32bd353381de587df69d8a0c936ae79e715e4033aabe989735b8ebf71f9beb76;

        bool res = P256.verifySignatureAllowMalleability(msgHash, r, s, pubKey[0], pubKey[1]);
        assertEq(res, true);
    }

    function testCheck() public {
        uint256 r = 0x8fb3ca2982598e182d1fe1b8508cdc07c8932e80ea7168b6b8cb361fbf90dae2;
        uint256 s = 0x32bd353381de587df69d8a0c936ae79e715e4033aabe989735b8ebf71f9beb76;

        bool res = p256check.check(msgHash, r, s, pubKey[0], pubKey[1]);
        assertEq(res, true);
    }

    function testCheckPacked() public {
        bytes memory packedSig = hex"8fb3ca2982598e182d1fe1b8508cdc07c8932e80ea7168b6b8cb361fbf90dae232bd353381de587df69d8a0c936ae79e715e4033aabe989735b8ebf71f9beb76";
        bool res = p256check.checkPacked(msgHash, packedSig, pubKey[0], pubKey[1]);
        assertEq(res, true);
    }

    function testUserOpHash() public {
        // userOp.sender = address(0);
        // userOp.nonce = 0;
        // userOp.callGasLimit = 0;
        // userOp.verificationGasLimit = 0;
        // userOp.preVerificationGas = 0;
        // userOp.maxFeePerGas = 0;
        // userOp.maxPriorityFeePerGas = 0;
        // bytes32 hash = p256check.getUserOpHash(userOp);
        // console2.logBytes32(hash);
        bytes memory sig = hex"34e71357422e721aa067568fe6365235a16bff85bc90ba77102d2ed230e42fe2a42a9422c52579f022c25c82009c0ec01e3fffcc566e86d9337399e83bff5652";
        bool res = p256check.checkPacked(userOpHash, sig, userOpKey[0], userOpKey[1]);
        assertEq(res, true);
    }

}


