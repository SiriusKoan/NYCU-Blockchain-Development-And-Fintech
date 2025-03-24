// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import "../src/withdraw.sol";
import "../src/withdrawFactory.sol";

contract DeployWithdrawFactoryScript is Script {
    WithdrawAnyERC20Factory factory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        factory = new WithdrawAnyERC20Factory(msg.sender);
        console.logAddress(address(factory));

        vm.stopBroadcast();
    }
}

contract DeployWithdrawScript is Script {
    address contractAddr;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        contractAddr = WithdrawAnyERC20Factory(0xd2f44A92bAAE925e0a98cCcb0D3589305BFCF2eE).deployContract();
        console.logAddress(address(contractAddr));

        vm.stopBroadcast();
    }
}