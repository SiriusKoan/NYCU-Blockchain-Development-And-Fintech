// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Lab1Contract.sol";

contract DeployLab1 is Script {
    function run() external {
        vm.startBroadcast(); // Start broadcasting transactions using the private key in `foundry.toml`

        Lab1Contract lab1 = new Lab1Contract(); // Deploy contract

        console.log("Lab1Contract deployed at:", address(lab1));

        vm.stopBroadcast(); // Stop broadcasting
    }
}
