// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/// @title Swappable Token
/// @dev An ERC20 token with additional restrictions for DEX interaction.
/// This contract is designed for use in a decentralized exchange (DEX) scenario, where tokens can be swapped.
/// The contract restricts the DEX from approving tokens on behalf of others to enhance security.
contract SwappableToken is ERC20 {
  /// @notice The address of the associated DEX instance.
  /// @dev This address is set during deployment and cannot be changed.
  address private _dex;

  /// @notice Deploys the Swappable Token contract.
  /// @dev Mints the initial supply to the deployer's address and sets the DEX address.
  /// @param dexInstance The address of the DEX instance that this token will interact with.
  /// @param name The name of the ERC20 token.
  /// @param symbol The symbol of the ERC20 token.
  /// @param initialSupply The initial supply of tokens to mint.
  constructor(
    address dexInstance,
    string memory name,
    string memory symbol,
    uint256 initialSupply
  ) ERC20(name, symbol) {
    _mint(msg.sender, initialSupply);
    _dex = dexInstance;
  }

  /// @notice Approves a spender to transfer tokens on behalf of an owner.
  /// @dev Overrides the ERC20 `approve` function to include a restriction: the DEX cannot approve tokens for others.
  /// This is done to prevent the DEX from arbitrarily controlling token allowances.
  /// @param owner The address of the token owner.
  /// @param spender The address of the spender who will be allowed to spend the tokens.
  /// @param amount The number of tokens the spender is approved to spend.
  /// @custom:restriction The `owner` cannot be the DEX address.
  function approve(address owner, address spender, uint256 amount) public {
    require(owner != _dex, 'InvalidApprover');
    super._approve(owner, spender, amount);
  }
}
