// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ShareToken is ERC20 {
    address public vaultAddress;

    constructor() ERC20("ShareToken", "ST") {}

    modifier onlyVault() {
        require(msg.sender == vaultAddress, "Only vault can call this function");
        _;
    }

    function setVaultAddress(address _vaultAddress) external {
        vaultAddress = _vaultAddress;
    }

    function mint(address to, uint256 amount) external onlyVault {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyVault {
        _burn(from, amount);
    }
}
