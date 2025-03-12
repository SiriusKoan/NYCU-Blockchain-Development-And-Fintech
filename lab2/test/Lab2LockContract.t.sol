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
        token.approve(address(lab2), type(uint256).max);

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
        assertEq(lab2.lockedTokens(user1), 100);
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
        assertEq(token.balanceOf(user1), 1000 * 10 ** 18);
    }

    function testUserTradeFunds() public {
        vm.prank(owner);
        lab2.setStartTime(10000000000);
        vm.deal(user1, 100);
        vm.prank(user1);
        lab2.lock{value: 100}();

        vm.prank(owner);
        assertEq(lab2.lockedTokens(user1), 100);

        vm.prank(owner);
        lab2.tradeUserFunds(30, user1);

        vm.prank(owner);
        assertEq(lab2.lockedTokens(user1), 70);
        vm.prank(owner);
        assertEq(lab2.tokenTakenByOwner(user1), 30);
    }

    function testFull() public {
        vm.prank(owner);
        lab2.setStartTime(10000000000);
        vm.prank(owner);
        lab2.setEndTime(0);

        // user1 locks 100 eth
        vm.deal(user1, 100);
        vm.prank(user1);
        lab2.lock{value: 100}();
        vm.prank(owner);
        assertEq(lab2.lockedTokens(user1), 100);

        // user1 unlocks
        vm.prank(user1);
        lab2.unlock();
        vm.prank(owner);
        assertEq(token.balanceOf(user1), 1000 * 10 ** 18);

        // user2 locks 200 eth
        vm.deal(user2, 200);
        vm.prank(user2);
        lab2.lock{value: 200}();
        vm.prank(owner);
        assertEq(lab2.lockedTokens(user2), 200);

        // owner executes tradeUserFunds with 50 eth on user2
        vm.prank(owner);
        lab2.tradeUserFunds(50, user2);
        vm.prank(owner);
        assertEq(lab2.lockedTokens(user2), 150);
        vm.prank(owner);
        assertEq(lab2.tokenTakenByOwner(user2), 50);

        // user2 unlocks
        vm.prank(user2);
        lab2.unlock();
        vm.prank(owner);
        assertEq(token.balanceOf(user2), 1000 * 10 ** 18 + 200 * 2500);
        assertEq(address(user2).balance, 0);
    }
}
