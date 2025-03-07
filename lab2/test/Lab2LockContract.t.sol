// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Lab2Token.sol";
import "../src/Lab2LockContract.sol";

contract Lab2LockContractTest is Test {
    Lab2LockContract lab2;
    Lab2Token token;
    address owner = address(0xabc);
    address user1 = address(0x123);
    address user2 = address(0x456);

    function setUp() public {
        vm.prank(owner);
        token = new Lab2Token();

        vm.prank(owner);
        lab2 = new Lab2LockContract(address(token));
        vm.prank(owner);
        lab2.setStartTime(0);
        vm.prank(owner);
        lab2.setEndTime(1000);
    }

    function testSetStartTime() public {
        vm.prank(owner);
        lab2.setStartTime(100);
        assertEq(lab2.startTime(), 100);
    }

    function testSetEndTime() public {
        vm.prank(owner);
        lab2.setEndTime(200);
        assertEq(lab2.endTime(), 200);
    }

    function testGetETH() public {
        vm.prank(owner);
        assertEq(lab2.getETH(), 0);

        vm.deal(address(lab2), 100);
        vm.prank(owner);
        assertEq(lab2.getETH(), 100);
    }

    function testLock() public {
        vm.expectRevert("Locking period has already started");
        lab2.lock{value: 100}();

        vm.prank(owner);
        lab2.setStartTime(10000000000);
        vm.deal(user1, 100);

        vm.prank(user1);
        lab2.lock{value: 100}();
        vm.prank(owner);
        assertEq(lab2.getLockedTokens(user1), 100);
    }

    function testUnlock() public {
        vm.prank(owner);
        lab2.setStartTime(10000000000);
        vm.deal(user1, 100);

        vm.prank(user1);
        lab2.lock{value: 100}();
        vm.prank(owner);

        lab2.setEndTime(0);
        vm.prank(user1);
        lab2.unlock();
        vm.prank(owner);
        assertEq(token.balanceOf(user1), 1000);
    }

    function testUserTradeFunds() public {}
}