// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./UnderlyingToken.sol";
import "./ShareToken.sol";

contract Vault {
    address public underlyingToken;
    address public shareToken;
    uint256 public totalShares = 0;
    address public owner;
    mapping(address => uint256) public underlyingBalances;

    constructor(address _underlyingToken, address _shareToken) {
        underlyingToken = _underlyingToken;
        shareToken = _shareToken;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function sharePrice() public view returns (uint256) {
        if (totalShares == 0) {
            return 1 * 1e18;
        }
        return UnderlyingToken(underlyingToken).balanceOf(address(this)) / totalShares;
    }

    function deposit(uint256 _amountUnderlying) external payable {
        require(_amountUnderlying > 0, "Amount must be greater than 0");
        uint256 sharesToMint = _amountUnderlying / sharePrice();
        UnderlyingToken(underlyingToken).transferFrom(msg.sender, address(this), _amountUnderlying);
        totalShares += sharesToMint;
        ShareToken(shareToken).mint(msg.sender, sharesToMint);
    }

    function withdraw(uint256 _amountShares) external {
        require(_amountShares > 0, "Amount must be greater than 0");
        require(ShareToken(shareToken).balanceOf(msg.sender) >= _amountShares, "Insufficient shares");
        uint256 tokenBack = _amountShares * sharePrice();
        totalShares -= _amountShares;
        ShareToken(shareToken).burn(msg.sender, _amountShares);
        UnderlyingToken(underlyingToken).transfer(msg.sender, tokenBack);
    }

    function takeFeeAsOwner(uint256 _amountUnderlying) external onlyOwner {
        require(_amountUnderlying > 0, "Amount must be greater than 0");
        require(
            UnderlyingToken(underlyingToken).balanceOf(address(this)) >= _amountUnderlying,
            "Insufficient underlying balance"
        );
        UnderlyingToken(underlyingToken).transfer(owner, _amountUnderlying);
    }
}
