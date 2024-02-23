// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import "p256-verifier/src/P256.sol";

contract P256Check {
    function check(bytes32 hash, uint256 r, uint256 s, uint256 x, uint256 y) view external returns(bool) {
        return P256.verifySignature(hash, r, s, x, y);
    }
}
