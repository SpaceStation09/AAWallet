// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import "./SimpleAccount.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "./interfaces/IEntryPoint.sol";

contract SimpleAccFactory {
    SimpleAccount public immutable accountImp;

    constructor(IEntryPoint _entryPoint) {
        accountImp = new SimpleAccount(_entryPoint);
    }

    function createAccount(
        uint256 _salt,
        address _owner
    ) external returns ( SimpleAccount) {
        address addr = computeAddress(_salt, _owner);
        uint256 codeSize = addr.code.length;
        if (codeSize > 0) {
            return SimpleAccount(payable(addr));
        } else {
            return SimpleAccount(payable(
                new ERC1967Proxy{salt: bytes32(_salt)}(
                    address(accountImp),
                    abi.encodeCall(
                        SimpleAccount.initialize,
                        (_owner)
                    )
                )
            ));
        }
    }

    function computeAddress(
        uint256 _salt,
        address _owner
    ) public view returns (address) {
        return Create2.computeAddress(bytes32(_salt), keccak256(abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(
                address(accountImp),
                abi.encodeCall(
                    SimpleAccount.initialize,
                    (_owner)
                )
            )
        )));
    }
}