// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/Create2.sol";
import "./withdraw.sol";

contract WithdrawAnyERC20Factory {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function computeAddress() public view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(owner));
        bytes memory creationCode = abi.encodePacked(type(WithdrawAnyERC20).creationCode, abi.encode(owner));
        bytes32 bytecodeHash = keccak256(creationCode);
        return Create2.computeAddress(salt, bytecodeHash);
    }

    function deployContract() public returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(owner));
        WithdrawAnyERC20 instance = new WithdrawAnyERC20{salt: salt}(owner);
        return address(instance);
    }
}
