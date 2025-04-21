// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UnderlyingToken} from "../src/UnderlyingToken.sol";
import {ShareToken} from "../src/ShareToken.sol";
import {Vault} from "../src/Vault.sol";

contract VaultBasicTest is Test {
    Vault public vault;
    UnderlyingToken public underlyingToken;
    ShareToken public shareToken;

    address owner = address(0xabc);
    address user1 = address(0x123);
    address user2 = address(0x456);

    function setUp() public {
        vm.startPrank(owner);
        underlyingToken = new UnderlyingToken();
        shareToken = new ShareToken();
        vault = new Vault(address(underlyingToken), address(shareToken));
        shareToken.setVaultAddress(address(vault));

        // Initial assets
        underlyingToken.transfer(user1, 1000 * 1e18);
        underlyingToken.transfer(user2, 1000 * 1e18);
        vm.stopPrank();
    }

    function testVaultInfo() public view {
        assertEq(vault.underlyingToken(), address(underlyingToken));
        assertEq(vault.shareToken(), address(shareToken));
        assertEq(vault.owner(), owner);
        assertEq(vault.sharePrice(), 1e18);
        assertEq(vault.totalShares(), 0);
    }

    function testDeposit() public {
        vm.startPrank(user1);
        underlyingToken.approve(address(vault), 100 * 1e18);
        vault.deposit(100 * 1e18);
        vm.stopPrank();

        assertEq(underlyingToken.balanceOf(address(user1)), (1000 - 100) * 1e18);
        assertEq(shareToken.balanceOf(address(user1)), 100);
        assertEq(vault.totalShares(), 100);
    }

    function testWithdraw() public {
        vm.startPrank(user1);
        underlyingToken.approve(address(vault), 100 * 1e18);
        vault.deposit(100 * 1e18);
        vm.stopPrank();

        vm.startPrank(user1);
        vault.withdraw(50);
        vm.stopPrank();

        assertEq(underlyingToken.balanceOf(address(user1)), (1000 - 100 + 50) * 1e18);
        assertEq(shareToken.balanceOf(address(user1)), 50);
        assertEq(vault.totalShares(), 50);
    }

    function testMultiUserDeposit() public {
        vm.startPrank(user1);
        underlyingToken.approve(address(vault), 100 * 1e18);
        vault.deposit(100 * 1e18);
        vm.stopPrank();

        vm.startPrank(user2);
        underlyingToken.approve(address(vault), 200 * 1e18);
        vault.deposit(200 * 1e18);
        vm.stopPrank();

        assertEq(underlyingToken.balanceOf(address(user1)), (1000 - 100) * 1e18);
        assertEq(underlyingToken.balanceOf(address(user2)), (1000 - 200) * 1e18);
        assertEq(shareToken.balanceOf(address(user1)), 100);
        assertEq(shareToken.balanceOf(address(user2)), 200);
        assertEq(vault.totalShares(), 300);
    }

    function testMultiUserWithdraw() public {
        vm.startPrank(user1);
        underlyingToken.approve(address(vault), 100 * 1e18);
        vault.deposit(100 * 1e18);
        vm.stopPrank();

        vm.startPrank(user2);
        underlyingToken.approve(address(vault), 200 * 1e18);
        vault.deposit(200 * 1e18);
        vm.stopPrank();

        vm.startPrank(user1);
        vault.withdraw(50);
        vm.stopPrank();

        vm.startPrank(user2);
        vault.withdraw(100);
        vm.stopPrank();

        assertEq(underlyingToken.balanceOf(address(user1)), (1000 - 100 + 50) * 1e18);
        assertEq(underlyingToken.balanceOf(address(user2)), (1000 - 200 + 100) * 1e18);
    }

    function testDonate() public {
        vm.startPrank(user1);
        underlyingToken.approve(address(vault), 100 * 1e18);
        vault.deposit(100 * 1e18);
        vm.stopPrank();

        assertEq(vault.totalShares(), 100);

        vm.startPrank(owner);
        underlyingToken.transfer(address(vault), 100 * 1e18);
        vm.stopPrank();

        assertEq(vault.totalShares(), 100);
        assertEq(underlyingToken.balanceOf(address(vault)), (100 + 100) * 1e18);
        assertEq(vault.sharePrice(), 2 * 1e18);
    }

    function testTakeFeeAsOwner() public {
        vm.startPrank(user1);
        underlyingToken.approve(address(vault), 100 * 1e18);
        vault.deposit(100 * 1e18);
        vm.stopPrank();

        vm.startPrank(user2);
        underlyingToken.approve(address(vault), 200 * 1e18);
        vault.deposit(200 * 1e18);
        vm.stopPrank();

        vm.startPrank(owner);
        vault.takeFeeAsOwner(150 * 1e18);
        vm.stopPrank();

        assertEq(underlyingToken.balanceOf(address(vault)), (100 + 200 - 150) * 1e18);
        assertEq(vault.totalShares(), 300);
        assertEq(vault.sharePrice(), 0.5 * 1e18);
    }
}
