// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Lab2Token is ERC20 {
    uint256 public constant INITIAL_SUPPLY = 100_000_000;

    constructor () ERC20("Lab2Token", "L2T") {
        _mint(msg.sender, INITIAL_SUPPLY * (10 ** decimals()));
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
