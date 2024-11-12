// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Dex } from './Dex.sol';
import { SwappableToken } from './SwappableToken.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract SetupContract {
  Dex public dex;
  SwappableToken public token1;
  SwappableToken public token2;

  uint256 public fuzzAmount = 1 * 10 ** 18;
  uint256 public adjustAmount = 5 * 10 ** 18; // значение для изменения баланса

  event SwapFinished(uint256 amount1, uint256 amount2);

  constructor() {
    dex = new Dex();
    token1 = new SwappableToken(address(dex), 'Token 1', 'TK1', 1000 * 10 ** 18);
    token2 = new SwappableToken(address(dex), 'Token 2', 'TK2', 1000 * 10 ** 18);

    dex.setTokens(address(token1), address(token2));

    token1.approve(address(dex), type(uint256).max);
    token2.approve(address(dex), type(uint256).max);

    dex.addLiquidity(address(token1), 100 * 10 ** 18);
    dex.addLiquidity(address(token2), 100 * 10 ** 18);

    token1.transfer(address(this), 10 * 10 ** 18);
    token2.transfer(address(this), 10 * 10 ** 18);

    // Отказ от владения
    dex.renounceOwnership();
  }

  function getSwapPrice_never_reverts(uint256 amount, bool reverseTokens) public {
    if (amount == 0) return;
    address from = reverseTokens ? address(token2) : address(token1);
    address to = reverseTokens ? address(token1) : address(token2);

    if (IERC20(from).balanceOf(msg.sender) < amount) {
      return;
    }

    (bool b, ) = address(dex).call(abi.encodeWithSignature('getSwapPrice(address,address,uint256)', from, to, amount));

    assert(b);
  }

  function swap_never_reverts(uint256 amount, bool reverseTokens) public {
    address from = reverseTokens ? address(token2) : address(token1);
    address to = reverseTokens ? address(token1) : address(token2);

    if (IERC20(from).balanceOf(msg.sender) < amount) {
      return;
    }

    (bool b, ) = address(dex).call(abi.encodeWithSignature('swap(address,address,uint256)', from, to, amount));
    assert(b);
  }

  function echidna_swap_is_always_same() public returns (bool) {
    emit SwapFinished(token1.balanceOf(msg.sender), token2.balanceOf(msg.sender));
    token1.transfer(msg.sender, 10 * 10 ** 18); // Даем 10 токенов
    token2.transfer(msg.sender, 10 * 10 ** 18); // Даем 10 токенов
    // require(amount == 1 * 10 ** 18, 'Amount must be less than 10 tokens');
    // require(attempts > 500, 'Attempts min limit is 500');

    uint256 amount = 1 * 10 ** 18;
    uint256 attempts = 10;

    uint256 initAmount1 = token1.balanceOf(msg.sender);
    uint256 initAmount2 = token2.balanceOf(msg.sender);

    for (uint256 i = 0; i < attempts; ++i) {
      address from = i % 2 == 0 ? address(token1) : address(token2);
      address to = i % 2 == 0 ? address(token2) : address(token1);

      require(IERC20(from).balanceOf(msg.sender) >= amount, 'Not enough balance');
      dex.approve(address(dex), amount);

      dex.swap(from, to, amount);
    }

    uint256 finalAmount1 = token1.balanceOf(address(this));
    uint256 finalAmount2 = token2.balanceOf(address(this));

    return finalAmount1 + finalAmount2 >= initAmount1 + initAmount2;
  }
}
