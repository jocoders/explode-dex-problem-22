# Explode Dex Problem 22

## Overview

This repository contains a solution to **Dex Problem 22** from a Solidity challenge, where the goal was to exploit vulnerabilities in a simple decentralized exchange (DEX) contract to manipulate token prices and drain funds.

The problem illustrates the importance of secure price calculation mechanisms in smart contracts, as price manipulation can result in significant losses. Using **Echidna**, a property-based testing tool, this repository demonstrates how to identify and exploit the vulnerability.

---

## Challenge Description

- **Objective**: Drain all tokens of at least one type from the DEX by manipulating the token prices.
- **Setup**:
  - You start with **10 tokens** of `token1` and **10 tokens** of `token2`.
  - The DEX contract starts with **100 tokens** of each type.
- **Conditions for success**:
  - Manipulate the DEX's price calculation to drain all tokens of at least one type.
  - Allow the DEX to report a "bad" price for the assets.

---

## Key Vulnerability

The vulnerability lies in the `getSwapPrice` function:

```solidity
function getSwapPrice(address from, address to, uint256 amount) public view returns (uint256) {
    return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
}
```

### Explanation:

- The price of a token is calculated based on the balance of tokens in the DEX contract.
- By swapping tokens back and forth repeatedly, the balances of `token1` and `token2` are manipulated, creating drastic price swings.
- This allows an attacker to exploit the price discrepancy to drain one of the token reserves entirely.

---

## Exploit Strategy

### Goal:

Exploit the vulnerability to manipulate token prices and drain the reserves of one token.

### Steps:

1. **Initial Setup**:

   - Transfer small amounts of `token1` and `token2` to the attacker contract.

2. **Price Manipulation**:

   - Perform multiple swaps between `token1` and `token2`.
   - Each swap manipulates the price by changing the balance of tokens in the DEX.

3. **Draining Reserves**:

   - After sufficient swaps, one token's price becomes significantly undervalued.
   - Use the manipulated price to drain the reserves of the undervalued token.

4. **Verification**:
   - Ensure that the total amount of tokens in the attacker's wallet has increased.
   - Verify that at least one token's reserve in the DEX is completely drained.

---

## Key Exploit Code

The following Echidna test demonstrates the exploit:

```solidity
function echidna_manipulate_swap() public returns (bool) {
    // Transfer initial tokens to the attacker contract
    token1.transfer(address(this), 10 * MUL);
    token2.transfer(address(this), 10 * MUL);

    uint256 amount = 1 * 10 ** 18; // Swap amount
    uint256 attempts = 100; // Number of swaps

    uint256 initAmount1 = token1.balanceOf(address(this));
    uint256 initAmount2 = token2.balanceOf(address(this));

    // Perform swaps to manipulate the price
    for (uint256 i = 0; i < attempts; ++i) {
        (address from, address to) = _swap_tokens_order(i % 2 == 0);
        require(IERC20(from).balanceOf(address(this)) >= amount, 'Not enough balance');
        dex.swap(from, to, amount);
    }

    uint256 finalAmount1 = token1.balanceOf(address(this));
    uint256 finalAmount2 = token2.balanceOf(address(this));

    // Ensure that no unintended profit was made during the swaps
    return finalAmount1 + finalAmount2 <= initAmount1 + initAmount2;
}
```

### Key Points:

- The repeated swaps manipulate the DEX's price calculation due to changes in token balances.
- The vulnerability is exploited to drain tokens from the DEX reserves.

---

## Lessons Learned

1. **Avoid Using Balances for Price Calculation**:

   - Using token balances directly to calculate prices introduces vulnerabilities.
   - Instead, use algorithms like **constant product formula** (e.g., Uniswap's AMM: `x * y = k`) to ensure price stability.

2. **Implement Swap Limits**:

   - Prevent excessive swaps within a short time frame to reduce price manipulation risks.

3. **Test with Property-Based Tools**:

   - Use tools like **Echidna** to test for logical vulnerabilities.
   - Define invariants to ensure token balances remain consistent under various scenarios.

4. **Secure Liquidity Pools**:
   - Implement mechanisms to prevent attackers from draining reserves by introducing slippage protection.

---

## Conclusion

The `Dex Problem 22` challenge highlights the risks of insecure price calculations in decentralized exchanges. By exploiting the dependency on token balances, this repository demonstrates how attackers can manipulate prices and drain reserves.

This solution uses **Echidna** to identify and exploit the vulnerability, providing a practical demonstration of the importance of secure smart contract design.

```

```
