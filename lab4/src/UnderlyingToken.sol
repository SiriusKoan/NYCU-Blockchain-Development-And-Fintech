// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract UnderlyingToken is ERC20 {
    constructor() ERC20("UnderlyingToken", "UT") {
        _mint(msg.sender, 100_000_000 * (10 ** 18));
    }
}
