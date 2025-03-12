// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Lab1Contract.sol";

contract Lab1ContractTest is Test {
    Lab1Contract lab1;
    address owner = address(0xabc);
    address user = address(0x123);

    function setUp() public {
        vm.prank(owner);
        lab1 = new Lab1Contract();
    }

    function testReceiveETH() public {
        vm.deal(user, 1 ether); // Give the user 1 ETH
        vm.prank(user);
        (bool success,) = address(lab1).call{value: 0.5 ether}("");
        assertTrue(success);
        assertEq(lab1.getBalance(), 0.5 ether);
    }

    function testEmitEthReceivedEvent() public {
        vm.deal(user, 1 ether);
        vm.prank(user);

        // Expect the EthReceived event to be emitted
        vm.expectEmit(true, true, false, true);
        emit Lab1Contract.EthReceived(user, 0.5 ether);

        (bool success,) = address(lab1).call{value: 0.5 ether}("");
        assertTrue(success);
    }

    function testWithdrawByOwner() public {
        vm.deal(address(lab1), 1 ether);
        vm.prank(owner);
        uint256 ownerBalanceBefore = owner.balance;

        lab1.withdraw();

        assertEq(owner.balance, ownerBalanceBefore + 1 ether);
        assertEq(lab1.getBalance(), 0);
    }

    function test_RevertWhen_NonOwnerWithdraw() public {
        vm.deal(address(lab1), 1 ether);
        vm.prank(user);
        vm.expectRevert("Not the owner");
        lab1.withdraw();
    }
}
