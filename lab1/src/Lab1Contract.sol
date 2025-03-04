// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Lab1Contract {
    address public owner;

    event EthReceived(address indexed sender, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    // Function to receive ETH
    receive() external payable {
        require(msg.value > 0, "Must send ETH");
        emit EthReceived(msg.sender, msg.value);
    }

    // Function to withdraw funds (only owner can call this)
    function withdraw() external {
        require(msg.sender == owner, "Not the owner");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdraw failed");

        emit Withdrawn(owner, balance);
    }

    // Function to check contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
