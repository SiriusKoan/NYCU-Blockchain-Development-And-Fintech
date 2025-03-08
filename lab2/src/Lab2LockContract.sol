// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Lab2Token.sol";

contract Lab2LockContract {
    address public owner;
    uint256 public startTime;
    uint256 public endTime;
    address public token;
    mapping(address => uint256) private lockedTokens;
    mapping(address => uint256) private tokenTakenByOwner;
    mapping(address => bool) private unlocked;

    event EthReceived(address indexed sender, uint256 amount);

    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    fallback() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(address _token) {
        token = _token;
        owner = msg.sender;
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        endTime = _endTime;
    }

    function getETH() public view onlyOwner returns(uint256) {
        return address(this).balance;
    }

    function getLockedTokens(address locker) public view onlyOwner returns(uint256) {
        return lockedTokens[locker];
    }

    function getTokenTakenByOwner(address locker) public view onlyOwner returns(uint256) {
        return tokenTakenByOwner[locker];
    }

    function getUnlocked(address locker) public view onlyOwner returns(bool) {
        return unlocked[locker];
    }

    function lock() external payable {
        // Check if the locking period has started
        require(block.timestamp < startTime, "Locking period has already started");

        // lock the tokens
        lockedTokens[msg.sender] += msg.value;
    }

    function unlock() external {
        // Check if the locking period has ended
        require(block.timestamp > endTime, "Locking period has not ended yet");
        // Check if the sender has already unlocked the tokens
        require(!unlocked[msg.sender], "Tokens already unlocked");
        // Check if the sender has locked tokens
        require(lockedTokens[msg.sender] > 0 || tokenTakenByOwner[msg.sender] > 0, "No tokens locked");

        // Get the rewarded amount
        uint256 reward = 0;
        if (tokenTakenByOwner[msg.sender] == 0) {
            reward = 1000;
            payable(msg.sender).transfer(lockedTokens[msg.sender]);
        } else {
            reward = 1000 + (lockedTokens[msg.sender] + tokenTakenByOwner[msg.sender]) * 2500;
        }

        // transfer the tokens
        Lab2Token(token).transferFrom(owner, msg.sender, reward);

        // reset the locked balance and set the unlocked flag
        lockedTokens[msg.sender] = 0;
        tokenTakenByOwner[msg.sender] = 0;
        unlocked[msg.sender] = true;
    }

    function tradeUserFunds(uint256 amount, address locker) external onlyOwner {
        require(lockedTokens[locker] > 0, "No locked tokens");
        require(amount <= lockedTokens[locker], "Amount exceeds locked tokens");

        // Do some trade
        lockedTokens[locker] -= amount;
        tokenTakenByOwner[locker] += amount;
    }
}