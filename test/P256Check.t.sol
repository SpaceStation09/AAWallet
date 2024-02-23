// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "p256-verifier/src/P256.sol";
import "p256-verifier/src/P256Verifier.sol";
import {Test} from "forge-std/Test.sol";

contract P256CheckTest is Test {
    uint256[2] public pubKey;
    
    function setUp() public {
        // Deploy P256 Verifier
        vm.etch(P256.VERIFIER, type(P256Verifier).runtimeCode);
        pubKey = [
            0x237fe99abb244bdcc8b153c9ef87f8899005880378ce1fa043f3d3c3ff064aec,
            0x7e0e6f6de9a4179cfe87ad03887143cec4b489bfdc4104f53e49bf6c28b75805
        ];
    }

    function testCheck() public {
        uint256 r = 0xd23e247c720600c5276f9a9331a16ff952c356166e96ac24ccb2172d4729b854;
        uint256 s = 0x6bb748f38b65e76f2e5ac9980b3c820f853e16863819a81128c6860fee1b3db1;

        bytes32 msgHash = 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855;

        bool res = P256.verifySignature(msgHash, r, s, pubKey[0], pubKey[1]);
        assertEq(res, true);
    }
}
