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
            0xa62627aea36470ecd8db4e8fd0954ac32111abea9aa33d7f7f5b61903f664699,
            0xb153326c272620c10fffd868798cb6f455a767c604970b3b4c6d18129ba3e8f1
        ];
        userOpKey = [
            0x442bcf22392f6011b6c2146cc6915963f7ab31ff1b81f9d346228962a33750cb,
            0x8683e3716b660f9d744c2823b73e4f4944b93ba5c55608aef0d07eb02af5f4b4
        ];
        msgHash = 0xc327f0f6049c45049bb338761823da7ff4b8315f4a6af553d889db24cb3989df;
        userOpHash = 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;
        p256check = new P256Check();
    }

    function testP256() public {
        uint256 r = 0x28485aed55aa65c43afa762ad2212cf52bbf304e2cb3d1ab427a1492823de8a0;
        uint256 s = 0x6f38fca868af01619eb8288749b6bf6e534677e2dbb0a89c780908efe603359d;

        bool res = P256.verifySignatureAllowMalleability(msgHash, r, s, pubKey[0], pubKey[1]);
        assertEq(res, true);
    }

    function testCheck() public {
        uint256 r = 0x28485aed55aa65c43afa762ad2212cf52bbf304e2cb3d1ab427a1492823de8a0;
        uint256 s = 0x6f38fca868af01619eb8288749b6bf6e534677e2dbb0a89c780908efe603359d;

        bool res = p256check.check(msgHash, r, s, pubKey[0], pubKey[1]);
        assertEq(res, true);
    }

    function testCheckPacked() public {
        bytes memory packedSig = hex"28485aed55aa65c43afa762ad2212cf52bbf304e2cb3d1ab427a1492823de8a06f38fca868af01619eb8288749b6bf6e534677e2dbb0a89c780908efe603359d";
        bool res = p256check.checkPacked(msgHash, packedSig, pubKey[0], pubKey[1]);
        assertEq(res, true);
    }

    // function testUserOpHash() public {
    //     // userOp.sender = address(0);
    //     // userOp.nonce = 0;
    //     // userOp.callGasLimit = 0;
    //     // userOp.verificationGasLimit = 0;
    //     // userOp.preVerificationGas = 0;
    //     // userOp.maxFeePerGas = 0;
    //     // userOp.maxPriorityFeePerGas = 0;
    //     // bytes32 hash = p256check.getUserOpHash(userOp);
    //     // console2.logBytes32(hash);
    //     bytes memory sig = hex"81d1ed8794b9a9355b225bee5367f5a917a807b2ce20e0286aa3d044e07ad8a43934b3abe485deb5e8c751c488302b26846197b148b6e7b0585dd750a779eaf5";
    //     bool res = p256check.checkPacked(userOpHash, sig, userOpKey[0], userOpKey[1]);
    //     assertEq(res, true);
    // }

}


