// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Lab2Token.sol";
import "../src/Lab2LockContract.sol";

contract DeployLab2 is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions using the private key in `foundry.toml`

        Lab2Token token = new Lab2Token(); // Deploy contract
        console.log("Lab2Token deployed at:", address(token));

        Lab2LockContract lab2 = new Lab2LockContract(address(token));
        console.log("Lab2LockContract deployed at:", address(lab2));

        token.approve(address(lab2), type(uint256).max);

        vm.stopBroadcast(); // Stop broadcasting
    }
}
