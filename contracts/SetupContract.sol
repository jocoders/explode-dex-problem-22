// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { Dex } from './Dex.sol';
import { SwappableToken } from './SwappableToken.sol';

/// @title SetupContract for Dex Testing with Echidna
/// @dev Provides functions to initialize, test, and exploit vulnerabilities in the Dex contract using Echidna.
contract SetupContract {
  Dex public dex;
  SwappableToken public token1;
  SwappableToken public token2;

  uint256 private constant MUL = 10 ** 18;
  uint256 private constant SUPPLY = 10_000_000 * MUL;

  event SwapArgs(uint256 amountToken1, uint256 amountToken2, uint256 amountSwap);
  event Balances(
    uint256 balanceInitToken1,
    uint256 balanceInitToken2,
    uint256 balanceFinalToken1,
    uint256 balanceFinalToken2
  );

  modifier validSwapAmount(uint256 amount) {
    require(amount <= SUPPLY, 'Amount must be less than SUPPLY');
    _;
  }

  modifier validSwapAmounts(
    uint256 amountToken1,
    uint256 amountToken2,
    uint256 amountSwap
  ) {
    require(amountToken1 <= SUPPLY, 'Amount token 1 must be less than SUPPLY');
    require(amountToken2 <= SUPPLY, 'Amount token 2 must be less than SUPPLY');
    require(amountSwap <= SUPPLY, 'Amount swap must be less than SUPPLY');
    _;
  }

  /// @dev Initializes the testing environment for the Dex.
  /// Deploys the Dex and two SwappableToken contracts, sets tokens, and adds initial liquidity.
  constructor() {
    dex = new Dex();
    token1 = new SwappableToken(address(dex), 'Token 1', 'TK1', SUPPLY * MUL);
    token2 = new SwappableToken(address(dex), 'Token 2', 'TK2', SUPPLY * MUL);

    dex.setTokens(address(token1), address(token2));

    token1.approve(address(dex), SUPPLY);
    token2.approve(address(dex), SUPPLY);

    dex.addLiquidity(address(token1), 100_000 * MUL);
    dex.addLiquidity(address(token2), 100_000 * MUL);

    dex.renounceOwnership();
  }

  /// @notice Ensures that getSwapPrice never reverts for valid parameters.
  /// @param amount The amount of tokens to calculate the swap price for.
  /// @param reverseTokens Whether to reverse the token pair in the calculation.
  function getSwapPrice_never_reverts(uint256 amount, bool reverseTokens) public view {
    (address from, address to) = _swap_tokens_order(reverseTokens);
    uint256 result = dex.getSwapPrice(from, to, amount);

    assert(result >= 0);
  }

  /// @notice Ensures that calling getSwapPrice through the Dex contract never reverts.
  /// @param amount The amount of tokens to calculate the swap price for.
  /// @param reverseTokens Whether to reverse the token pair in the calculation.
  function getSwapPrice_call_never_reverts(uint256 amount, bool reverseTokens) public {
    (address from, address to) = _swap_tokens_order(reverseTokens);
    (bool b, ) = address(dex).call(abi.encodeWithSignature('getSwapPrice(address,address,uint256)', from, to, amount));

    uint256 balanceFrom = IERC20(from).balanceOf(address(dex));
    uint256 balanceTo = IERC20(to).balanceOf(address(dex));

    emit SwapArgs(balanceFrom, balanceTo, amount);

    assert(b);
  }

  /// @notice Ensures that calling the swap function never reverts for valid parameters.
  /// @param amountToken1 The amount of Token 1 to transfer to the contract.
  /// @param amountToken2 The amount of Token 2 to transfer to the contract.
  /// @param amountSwap The amount of tokens to swap.
  /// @param reverseTokens Whether to reverse the token pair in the swap.
  function swap_call_never_reverts(
    uint256 amountToken1,
    uint256 amountToken2,
    uint256 amountSwap,
    bool reverseTokens
  ) public validSwapAmounts(amountToken1, amountToken2, amountSwap) {
    _transfer_tokens(amountToken1, amountToken2);
    (address from, address to) = _swap_tokens_order(reverseTokens);

    if (IERC20(from).balanceOf(address(this)) < amountSwap) {
      return;
    }

    (bool swapSuccess, ) = address(dex).call(
      abi.encodeWithSignature('swap(address,address,uint256)', from, to, amountSwap)
    );

    assert(swapSuccess);
  }

  /// @notice Ensures the swapped amount is correctly deducted and balances match expectations.
  /// @param amountToken1 The amount of Token 1 to transfer to the contract.
  /// @param amountToken2 The amount of Token 2 to transfer to the contract.
  /// @param amountSwap The amount of tokens to swap.
  /// @param reverseTokens Whether to reverse the token pair in the swap.
  function swap_always_tranfer_correct_amount(
    uint256 amountToken1,
    uint256 amountToken2,
    uint256 amountSwap,
    bool reverseTokens
  ) public validSwapAmounts(amountToken1, amountToken2, amountSwap) {
    // FAILED: amountToken1=0, amountToken2=0, amountSwap=0
    require(amountSwap > 0, 'Amount must be greater than 0');

    _transfer_tokens(amountToken1, amountToken2);
    (address from, address to) = _swap_tokens_order(reverseTokens);

    uint256 balanceInit = IERC20(from).balanceOf(address(this));
    uint256 dexBalanceInitToken1 = IERC20(token1).balanceOf(address(dex));
    uint256 dexBalanceInitToken2 = IERC20(token2).balanceOf(address(dex));

    if (balanceInit < amountSwap) {
      return;
    }

    dex.swap(from, to, amountSwap);

    uint256 balanceFinal = IERC20(from).balanceOf(address(this));
    uint256 dexBalanceFinalToken1 = IERC20(token1).balanceOf(address(dex));
    uint256 dexBalanceFinalToken2 = IERC20(token2).balanceOf(address(dex));

    emit SwapArgs(amountToken1, amountToken2, amountSwap);
    emit Balances(dexBalanceInitToken1, dexBalanceInitToken2, dexBalanceFinalToken1, dexBalanceFinalToken2);

    assert(balanceFinal == balanceInit - amountSwap);
  }

  /// @notice Ensures the swap functionality cannot manipulate token balances inappropriately.
  /// @return `true` if the token balances remain consistent after multiple swaps.
  function echidna_manipulate_swap() public returns (bool) {
    token1.transfer(address(this), 10 * MUL);
    token2.transfer(address(this), 10 * MUL);

    uint256 amount = 1 * 10 ** 18;
    uint256 attempts = 100;

    uint256 initAmount1 = token1.balanceOf(address(this));
    uint256 initAmount2 = token2.balanceOf(address(this));

    for (uint256 i = 0; i < attempts; ++i) {
      (address from, address to) = _swap_tokens_order(i % 2 == 0);
      require(IERC20(from).balanceOf(address(this)) >= amount, 'Not enough balance');
      dex.swap(from, to, amount);
    }

    uint256 finalAmount1 = token1.balanceOf(address(this));
    uint256 finalAmount2 = token2.balanceOf(address(this));

    return finalAmount1 + finalAmount2 <= initAmount1 + initAmount2;
  }

  /// @notice Ensures that after a token swap, the total token balance does not increase.
  /// @dev This function tests that the total of `token1` and `token2` balances for the caller
  /// after a swap is always less than or equal to the total balances before the swap.
  /// It checks for any unintended balance manipulations or exploits in the swap logic.
  /// @param amountToken1 The amount of `token1` to transfer to the contract before the swap.
  /// @param amountToken2 The amount of `token2` to transfer to the contract before the swap.
  /// @param amountSwap The amount of tokens to swap from one type to the other.
  /// @param reverseTokens A boolean that determines the direction of the swap.
  /// If `true`, swaps from `token2` to `token1`; otherwise, swaps from `token1` to `token2`.
  function swap_always_transfer_less(
    uint256 amountToken1,
    uint256 amountToken2,
    uint256 amountSwap,
    bool reverseTokens
  ) public validSwapAmounts(amountToken1, amountToken2, amountSwap) {
    require(amountSwap > 0, 'Swap amount must be greater than 0');

    _transfer_tokens(amountToken1, amountToken2);

    uint256 initBalance1 = token1.balanceOf(address(this));
    uint256 initBalance2 = token2.balanceOf(address(this));

    (address from, address to) = _swap_tokens_order(reverseTokens);
    require(IERC20(from).balanceOf(address(this)) >= amountSwap, 'Balance must be greater than swap amount');
    dex.swap(from, to, amountSwap);
    uint256 finalBalance1 = token1.balanceOf(address(this));
    uint256 finalBalance2 = token2.balanceOf(address(this));

    emit SwapArgs(amountToken1, amountToken2, amountSwap);
    emit Balances(initBalance1, initBalance2, finalBalance1, finalBalance2);

    assert(finalBalance1 + finalBalance2 <= initBalance1 + initBalance2);
  }

  /// @dev Internal helper to determine the order of tokens for a swap.
  /// @param reverseTokens Whether to reverse the token pair order.
  /// @return from The address of the token to swap from.
  /// @return to The address of the token to swap to.
  function _swap_tokens_order(bool reverseTokens) internal view returns (address from, address to) {
    from = reverseTokens ? address(token2) : address(token1);
    to = reverseTokens ? address(token1) : address(token2);
  }

  /// @dev Internal helper to transfer tokens to the contract.
  /// @param amountToken1 The amount of Token 1 to transfer.
  /// @param amountToken2 The amount of Token 2 to transfer.
  function _transfer_tokens(uint256 amountToken1, uint256 amountToken2) internal {
    if (amountToken1 > 0) {
      token1.transfer(address(this), amountToken1);
    }
    if (amountToken2 > 0) {
      token2.transfer(address(this), amountToken2);
    }
  }
}
