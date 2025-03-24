// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/withdraw.sol";
import "../src/withdrawFactory.sol";

contract WithdrawTest is Test {
    address owner = address(0x123);
    WithdrawAnyERC20Factory factory;

    function setUp() public {
        factory = new WithdrawAnyERC20Factory(owner);
    }

    function testDeployContract() public {
        vm.prank(owner);
        address computedAddr = factory.computeAddress();
        vm.prank(owner);
        address deployedAddr = factory.deployContract();

        assertEq(computedAddr, deployedAddr);
    }
}
