// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/Create2.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract WithdrawAnyERC20 {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function withdrawToken(address _token, uint256 _amount) external {
        require(msg.sender == owner, "only owner can withdraw");
        IERC20(_token).transfer(owner, _amount);
    }
}
