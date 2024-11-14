## 1.Two the almost same tests getSwapPrice_never_reverts & getSwapPrice_call_never_reverts, why getSwapPrice_never_reverts does not revert?

But getSwapPrice_call_never_reverts does?

## 2.swap_never_reverts:

The test swap_never_reverts(uint256 amount, bool reverseTokens) fails consistently in Echidna. Specifically, it fails when amount is set to 1 and reverseTokens is false.

Iterations: The failure occurs consistently across multiple iterations with amount = 1.
Condition: The test fails on the assertion assert(finalBalance == initBalance - amount);
Despite transferring amount tokens from msg.sender to Dex, the finalBalance does not reflect the expected decrease by amount.
Observation: The balance of msg.sender remains unchanged after the swap call, causing the assertion to fail.

## 3.manipulate_swap

When test is failed it shows the Event from the failed test?

Condition: assert(finalAmount1 + finalAmount2 >= initAmount1 + initAmount2);

emit AssertionFailed(finalAmount1=898999999999999999999, finalAmount2=899000000000000000001, initAmount1=1000000000000000000, initAmount2=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:170)

```
emit EmitSwapInfo(tokenAmount=1, swapAmount=1, attempts=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:147)
call SwappableToken::transfer(address,uint256)(Context, 1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:153)
├╴emit Transfer(from=SetupContract, to=Context, value=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
└╴← (true)
call SwappableToken::transfer(address,uint256)(Context, 1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:154)
├╴emit Transfer(from=SetupContract, to=Context, value=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
└╴← (true)
call SwappableToken::balanceOf(address)(Context) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:156)
└╴← (1000000000000000000)
call SwappableToken::balanceOf(address)(Context) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:157)
└╴← (1000000000000000000)
call Dex::approve(address,uint256)(Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:163)
├╴call SwappableToken::approve(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:40)
│ ├╴emit Approval(owner=SetupContract, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x
├╴call SwappableToken::approve(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:41)
│ ├╴emit Approval(owner=SetupContract, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x
└╴← 0x
call Dex::swap(address,address,uint256)(SwappableToken, SwappableToken, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:164)
├╴call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:26)
│ └╴← (899000000000000000000)
├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
│ └╴← (100000000000000000000)
├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
│ └╴← (100000000000000000000)
├╴call SwappableToken::transferFrom(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:30)
│ ├╴emit Transfer(from=SetupContract, to=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
│ └╴← (true)
├╴call SwappableToken::approve(address,uint256)(Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:31)
│ ├╴emit Approval(owner=Dex, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x0000000000000000000000000000000000000000000000000000000000000001
├╴call SwappableToken::transferFrom(address,address,uint256)(Dex, SetupContract, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:32)
│ ├╴emit Transfer(from=Dex, to=SetupContract, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
│ └╴← (true)
└╴← 0x
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:167)
└╴← (898999999999999999999)
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:168)
└╴← (899000000000000000001)
emit AssertionFailed(finalAmount1=898999999999999999999, finalAmount2=899000000000000000001, initAmount1=1000000000000000000, initAmount2=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:170)
```

## 4. manipulate_swap

After change
Condition: assert(finalAmount1 + finalAmount2 <= initAmount1 + initAmount2);
And anyway test failed:

```
emit EmitSwapInfo(tokenAmount=1, swapAmount=1, attempts=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:145)
call SwappableToken::transfer(address,uint256)(Context, 1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:151)
├╴emit Transfer(from=SetupContract, to=Context, value=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
└╴← (true)
call SwappableToken::transfer(address,uint256)(Context, 1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:152)
├╴emit Transfer(from=SetupContract, to=Context, value=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
└╴← (true)
call SwappableToken::balanceOf(address)(Context) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:154)
└╴← (1000000000000000000)
call SwappableToken::balanceOf(address)(Context) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:155)
└╴← (1000000000000000000)
call Dex::approve(address,uint256)(Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:161)
├╴call SwappableToken::approve(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:40)
│ ├╴emit Approval(owner=SetupContract, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x
├╴call SwappableToken::approve(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:41)
│ ├╴emit Approval(owner=SetupContract, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x
└╴← 0x
call Dex::swap(address,address,uint256)(SwappableToken, SwappableToken, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:162)
├╴call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:26)
│ └╴← (899000000000000000000)
├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
│ └╴← (100000000000000000000)
├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
│ └╴← (100000000000000000000)
├╴call SwappableToken::transferFrom(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:30)
│ ├╴emit Transfer(from=SetupContract, to=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
│ └╴← (true)
├╴call SwappableToken::approve(address,uint256)(Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:31)
│ ├╴emit Approval(owner=Dex, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x0000000000000000000000000000000000000000000000000000000000000001
├╴call SwappableToken::transferFrom(address,address,uint256)(Dex, SetupContract, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:32)
│ ├╴emit Transfer(from=Dex, to=SetupContract, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
│ └╴← (true)
└╴← 0x
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:165)
└╴← (898999999999999999999)
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:166)
└╴← (899000000000000000001)
emit AssertionFailed(finalAmount1=898999999999999999999, finalAmount2=899000000000000000001, initAmount1=1000000000000000000, initAmount2=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:168)

token1(): passing
AssertionFailed(..): failed!💥
Call sequence:
SetupContract.manipulate_swap(1,1,1)

Traces:
emit EmitSwapInfo(tokenAmount=1, swapAmount=1, attempts=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:145)
call SwappableToken::transfer(address,uint256)(Context, 1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:151)
├╴emit Transfer(from=SetupContract, to=Context, value=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
└╴← (true)
call SwappableToken::transfer(address,uint256)(Context, 1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:152)
├╴emit Transfer(from=SetupContract, to=Context, value=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
└╴← (true)
call SwappableToken::balanceOf(address)(Context) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:154)
└╴← (1000000000000000000)
call SwappableToken::balanceOf(address)(Context) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:155)
└╴← (1000000000000000000)
call Dex::approve(address,uint256)(Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:161)
├╴call SwappableToken::approve(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:40)
│ ├╴emit Approval(owner=SetupContract, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x
├╴call SwappableToken::approve(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:41)
│ ├╴emit Approval(owner=SetupContract, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x
└╴← 0x
call Dex::swap(address,address,uint256)(SwappableToken, SwappableToken, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:162)
├╴call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:26)
│ └╴← (899000000000000000000)
├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
│ └╴← (100000000000000000000)
├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
│ └╴← (100000000000000000000)
├╴call SwappableToken::transferFrom(address,address,uint256)(SetupContract, Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:30)
│ ├╴emit Transfer(from=SetupContract, to=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
│ └╴← (true)
├╴call SwappableToken::approve(address,uint256)(Dex, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:31)
│ ├╴emit Approval(owner=Dex, spender=Dex, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
│ └╴← 0x0000000000000000000000000000000000000000000000000000000000000001
├╴call SwappableToken::transferFrom(address,address,uint256)(Dex, SetupContract, 1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:32)
│ ├╴emit Transfer(from=Dex, to=SetupContract, value=1) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
│ └╴← (true)
└╴← 0x
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:165)
└╴← (898999999999999999999)
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:166)
└╴← (899000000000000000001)
emit AssertionFailed(finalAmount1=898999999999999999999, finalAmount2=899000000000000000001, initAmount1=1000000000000000000, initAmount2=1000000000000000000) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:168)
```
