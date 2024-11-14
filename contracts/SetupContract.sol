// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Dex } from './Dex.sol';
import { SwappableToken } from './SwappableToken.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract SetupContract {
  Dex public dex;
  SwappableToken public token1;
  SwappableToken public token2;

  uint256 public constant MUL = 10 ** 18;

  event SwapFinished(uint256 amount1, uint256 amount2);
  event EmitSwapInfo(uint256 tokenAmount, uint256 swapAmount, uint256 attempts);
  event AssertionFailed(uint256 finalAmount1, uint256 finalAmount2, uint256 initAmount1, uint256 initAmount2);
  event InitSwapInfo(uint256 initBalance, uint256 amount);
  event FinalSwapInfo(uint256 finalBalance, uint256 amount);

  constructor() {
    dex = new Dex();
    token1 = new SwappableToken(address(dex), 'Token 1', 'TK1', 1000 * MUL);
    token2 = new SwappableToken(address(dex), 'Token 2', 'TK2', 1000 * MUL);

    dex.setTokens(address(token1), address(token2));

    token1.approve(address(dex), type(uint256).max);
    token2.approve(address(dex), type(uint256).max);

    dex.addLiquidity(address(token1), 100 * MUL);
    dex.addLiquidity(address(token2), 100 * MUL);

    token1.transfer(address(this), 10 * MUL);
    token2.transfer(address(this), 10 * MUL);

    dex.renounceOwnership();
  }

  function getSwapPrice_never_reverts(uint256 amount, bool reverseTokens) public view {
    address from = reverseTokens ? address(token2) : address(token1);
    address to = reverseTokens ? address(token1) : address(token2);
    uint256 result = dex.getSwapPrice(from, to, amount);

    assert(result >= 0);
  }

  function getSwapPrice_call_never_reverts(uint256 amount, bool reverseTokens) public {
    token1.transfer(msg.sender, 10 * MUL);
    token2.transfer(msg.sender, 10 * MUL);

    address from = reverseTokens ? address(token2) : address(token1);
    address to = reverseTokens ? address(token1) : address(token2);

    (bool b, ) = address(dex).call(abi.encodeWithSignature('getSwapPrice(address,address,uint256)', from, to, amount));

    assert(b);
  }

  function swap_call_never_reverts(uint256 amount, bool reverseTokens) public {
    token1.transfer(msg.sender, 10 * MUL);
    token2.transfer(msg.sender, 10 * MUL);

    address from = reverseTokens ? address(token2) : address(token1);
    address to = reverseTokens ? address(token1) : address(token2);

    if (IERC20(from).balanceOf(msg.sender) < amount) {
      return;
    }

    dex.approve(address(dex), amount);

    (bool b, ) = address(dex).call(abi.encodeWithSignature('swap(address,address,uint256)', from, to, amount));
    assert(b);
  }

  function swap_never_reverts(uint256 amount, bool reverseTokens) public {
    require(amount > 0, 'Amount must be greater than 0');
    token1.transfer(msg.sender, 10 * MUL);
    token2.transfer(msg.sender, 10 * MUL);

    address from = reverseTokens ? address(token2) : address(token1);
    address to = reverseTokens ? address(token1) : address(token2);

    uint256 initBalance = IERC20(from).balanceOf(msg.sender);

    if (initBalance < amount) {
      return;
    }

    emit InitSwapInfo(initBalance, amount);

    dex.approve(address(dex), amount);
    dex.swap(from, to, amount);

    uint256 finalBalance = IERC20(from).balanceOf(msg.sender);

    emit FinalSwapInfo(finalBalance, amount);

    //assert(finalBalance == initBalance - amount);
    assert(finalBalance < initBalance);
  }

  function echidna_check_transfer() public returns (bool) {
    token1.transfer(msg.sender, 10 * MUL); // Даем 10 токенов
    token2.transfer(msg.sender, 10 * MUL);

    uint256 balance1 = token1.balanceOf(msg.sender);
    uint256 balance2 = token2.balanceOf(msg.sender);

    return balance1 == 10 * MUL && balance2 == 10 * MUL;
  }

  function echidna_manipulate_swap() public returns (bool) {
    token1.transfer(msg.sender, 10 * MUL);
    token2.transfer(msg.sender, 10 * MUL);

    uint256 amount = 1 * 10 ** 18;
    uint256 attempts = 100;

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

    return finalAmount1 + finalAmount2 <= initAmount1 + initAmount2;
  }

  function manipulate_swap(uint256 tokenAmount, uint256 swapAmount, uint256 attempts) public {
    emit EmitSwapInfo(tokenAmount, swapAmount, attempts);
    require(attempts > 0, 'Attempts must be greater than 0');
    require(swapAmount > 0, 'Swap amount must be greater than 0');
    require(tokenAmount > 0, 'Token amount must be greater than 0');
    require(swapAmount <= tokenAmount, 'Swap amount must be less than token amount');

    token1.transfer(msg.sender, tokenAmount * MUL);
    token2.transfer(msg.sender, tokenAmount * MUL);

    uint256 initAmount1 = token1.balanceOf(msg.sender);
    uint256 initAmount2 = token2.balanceOf(msg.sender);

    for (uint256 i = 0; i < attempts; ++i) {
      address from = i % 2 == 0 ? address(token1) : address(token2);
      address to = i % 2 == 0 ? address(token2) : address(token1);

      dex.approve(address(dex), swapAmount);
      dex.swap(from, to, swapAmount);
    }

    uint256 finalAmount1 = token1.balanceOf(address(this));
    uint256 finalAmount2 = token2.balanceOf(address(this));

    emit AssertionFailed(finalAmount1, finalAmount2, initAmount1, initAmount2);

    assert(finalAmount1 + finalAmount2 <= initAmount1 + initAmount2);
  }
}
