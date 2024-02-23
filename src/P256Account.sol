// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "p256-verifier/src/P256.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

import "./basic/BaseAccount.sol";
import "./utils/TokenCallbackHandler.sol";

/**
 * p256 signature account
 *  this is a sample minimal p256-signature account
 *  has basic execute, eth handling methods
 *  a single secp256r1 keypair as the owner.
 */

contract P256Account {

}