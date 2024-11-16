// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';
import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { SwappableToken } from './SwappableToken.sol';

/// @title Decentralized Exchange (Dex)
/// @dev A simple decentralized exchange contract allowing swaps between two tokens.
contract Dex is Ownable {
  /// @notice Address of the first token supported by the exchange.
  address public token1;

  /// @notice Address of the second token supported by the exchange.
  address public token2;

  /// @dev Initializes the Dex contract with the owner set to the deployer.
  constructor() Ownable(msg.sender) {}

  /// @notice Sets the two tokens that can be traded on this Dex.
  /// @dev This function can only be called by the owner.
  /// @param _token1 The address of the first token.
  /// @param _token2 The address of the second token.
  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }

  /// @notice Adds liquidity to the exchange for a specified token.
  /// @dev Transfers tokens from the owner to the Dex contract.
  /// @param token_address The address of the token to add liquidity for.
  /// @param amount The amount of tokens to add.
  /// @custom:restriction Only the contract owner can add liquidity.
  function addLiquidity(address token_address, uint256 amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }

  /// @notice Swaps tokens from one type to another.
  /// @dev Supports swapping between the two tokens specified in `setTokens`.
  /// @param from The address of the token to swap from.
  /// @param to The address of the token to swap to.
  /// @param amount The amount of the `from` token to swap.
  function swap(address from, address to, uint256 amount) public {
    require((from == token1 && to == token2) || (from == token2 && to == token1), 'Invalid tokens');
    require(IERC20(from).balanceOf(msg.sender) >= amount, 'Not enough to swap');

    uint256 swapAmount = getSwapPrice(from, to, amount);

    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  /// @notice Calculates the price of a token swap.
  /// @dev Uses the formula: `(amount * balanceOf(to)) / balanceOf(from)`.
  /// @param from The address of the token to swap from.
  /// @param to The address of the token to swap to.
  /// @param amount The amount of the `from` token to swap.
  /// @return The amount of the `to` token that will be received.
  function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
    return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
  }

  /// @notice Approves a spender to transfer tokens on behalf of the caller.
  /// @dev Calls the `approve` function for both `token1` and `token2`.
  /// @param spender The address of the spender.
  /// @param amount The amount of tokens to approve for transfer.
  function approve(address spender, uint256 amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  /// @notice Retrieves the token balance of a specific account.
  /// @param token The address of the token.
  /// @param account The address of the account to query.
  /// @return The balance of the specified account for the given token.
  function balanceOf(address token, address account) public view returns (uint256) {
    return IERC20(token).balanceOf(account);
  }
}
