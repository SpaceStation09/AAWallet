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
    UserOperation userOp;
    
    function setUp() public {
        // Deploy P256 Verifier
        vm.etch(P256.VERIFIER, type(P256Verifier).runtimeCode);
        pubKey = [
            0xa62627aea36470ecd8db4e8fd0954ac32111abea9aa33d7f7f5b61903f664699,
            0xb153326c272620c10fffd868798cb6f455a767c604970b3b4c6d18129ba3e8f1
        ];
        userOpKey = [
            0xc41782305e21f784a180e97d7ff3a4880423d1b18305930bb6c536c51dbdb746,
            0x0f484173b30289fede0421e4b0c1acbcbfc721c3c2e6efc3a878171dec2db017
        ];
        msgHash = 0xc327f0f6049c45049bb338761823da7ff4b8315f4a6af553d889db24cb3989df;
        p256check = new P256Check();
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

    function testUserOpHash() public {
        userOp.sender = address(0);
        userOp.nonce = 0;
        userOp.callGasLimit = 0;
        userOp.verificationGasLimit = 0;
        userOp.preVerificationGas = 0;
        userOp.maxFeePerGas = 0;
        userOp.maxPriorityFeePerGas = 0;
        bytes memory sig = hex"46dfdae4ad8e782122a82b155081377a53d4149265a8485d85567ade342b3ebd8ba85d4ed8543d4e3f75a73d2aa337625f409846e32ec4a4f0128befbd35039e";
        bool res = p256check.checkUserOp(userOp, sig, userOpKey[0], userOpKey[1]);
        assertEq(res, true);
    }

}


