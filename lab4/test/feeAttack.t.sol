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
    address user = address(0x123);

    function setUp() public {
        vm.startPrank(owner);
        underlyingToken = new UnderlyingToken();
        shareToken = new ShareToken();
        vault = new Vault(address(underlyingToken), address(shareToken));
        shareToken.setVaultAddress(address(vault));

        // Initial assets
        underlyingToken.transfer(user, 100000 * 1e18);
        vm.stopPrank();
    }

    function testFeeAttack() public {
        uint256 ownerInitAssets = underlyingToken.balanceOf(owner);

        // user deposit
        vm.startPrank(user);
        underlyingToken.approve(address(vault), 100 * 1e18);
        vault.deposit(100 * 1e18);
        vm.stopPrank();
        assertEq(vault.sharePrice(), 1e18);
        assertEq(shareToken.balanceOf(user), 100);

        // owner takes all underlying in vault
        vm.startPrank(owner);
        vault.takeFeeAsOwner(100 * 1e18);
        vm.stopPrank();
        assertEq(underlyingToken.balanceOf(owner), ownerInitAssets + 100 * 1e18);

        // user withdraw but gets 0 underlying
        assertEq(vault.sharePrice(), 0);
        assertEq(shareToken.balanceOf(user), 100);
        vm.startPrank(user);
        vault.withdraw(100);
        vm.stopPrank();
        assertEq(shareToken.balanceOf(user), 0);
        assertEq(underlyingToken.balanceOf(user), (100000 - 100) * 1e18);
    }
}
