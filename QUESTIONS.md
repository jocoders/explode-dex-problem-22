## 1.getSwapPrice_never_reverts VS getSwapPrice_call_never_reverts

```
[2024-11-14 15:53:11.77] Compiling .... Done! (15.407561s)
Analyzing contract: /Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:SetupContract
[2024-11-14 15:53:27.18] Running slither on .... Done! (2.234506s)
token2(): passing
getSwapPrice_never_reverts(uint256,bool): passing
dex(): passing
MUL(): passing
getSwapPrice_call_never_reverts(uint256,bool): failed!💥
  Call sequence:
    SetupContract.getSwapPrice_call_never_reverts(1158002774609361659164312407936767713753540478109084780679,false)

Traces:
call Dex::getSwapPrice(address,address,uint256)(SwappableToken, SwappableToken, 1158002774609361659164312407936767713753540478109084780679) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:53)
 ├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
 │  └╴← (100000000000000000000)
 ├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
 │  └╴← (100000000000000000000)
 └╴error Revert Panic(0x4e487b710000000000000000000000000000000000000000000000000000000000000011) <source not found>
call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:55)
 └╴← (100000000000000000000)
call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:56)
 └╴← (100000000000000000000)
emit GetSwapPriceArgs(balanceToken1=100000000000000000000, balanceToken2=100000000000000000000, swapAmount=1158002774609361659164312407936767713753540478109084780679) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:58)

token1(): passing
AssertionFailed(..): passing


Unique instructions: 5623
Unique codehashes: 3
Corpus size: 7
Seed: 7836240460066771523
```

Whats wrong? What the diff between this funcitons?

## 2.swap_always_transfer_less:

Every time is FAILED and the result does not depends on the sign for condition in assert >= | <=

```
[2024-11-14 20:22:27.21] Compiling .... Done! (15.330744s)
Analyzing contract: /Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:SetupContract
[2024-11-14 20:22:42.55] Running slither on .... Done! (2.18253s)
token2(): passing
dex(): passing
token1(): passing
swap_always_transfer_less(uint256,uint256,uint256,bool): failed!💥
  Call sequence:
    SetupContract.swap_always_transfer_less(0,0,166175873,true)
    SetupContract.swap_always_transfer_less(0,0,301029198343215,false)

Traces:
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:184)
 └╴← (9999999999999999999900000000000000166175873)
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:185)
 └╴← (9999999999999999999899999999999999833824127)
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:188)
 └╴← (9999999999999999999900000000000000166175873)
call Dex::swap(address,address,uint256)(SwappableToken, SwappableToken, 301029198343215) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:189)
 ├╴call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:26)
 │  └╴← (9999999999999999999900000000000000166175873)
 ├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
 │  └╴← (99999999999999833824127)
 ├╴call SwappableToken::balanceOf(address)(Dex) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:36)
 │  └╴← (100000000000000166175873)
 ├╴call SwappableToken::transferFrom(address,address,uint256)(SetupContract, Dex, 301029198343215) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:30)
 │  ├╴emit Transfer(from=SetupContract, to=Dex, value=301029198343215) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
 │  └╴← (true)
 ├╴call SwappableToken::approve(address,uint256)(Dex, 301029198343216) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:31)
 │  ├╴emit Approval(owner=Dex, spender=Dex, value=301029198343216) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:289)
 │  └╴← 0x0000000000000000000000000000000000000000000000000000000000000001
 ├╴call SwappableToken::transferFrom(address,address,uint256)(Dex, SetupContract, 301029198343216) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/Dex.sol:32)
 │  ├╴emit Transfer(from=Dex, to=SetupContract, value=301029198343216) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol:210)
 │  └╴← (true)
 └╴← 0x
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:190)
 └╴← (9999999999999999999899999999698970967832658)
call SwappableToken::balanceOf(address)(SetupContract) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:191)
 └╴← (9999999999999999999900000000301029032167343)
emit SwapArgs(amountToken1=0, amountToken2=0, amountSwap=301029198343215) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:193)
emit Balances(balanceInitToken1=9999999999999999999900000000000000166175873, balanceInitToken2=9999999999999999999899999999999999833824127, balanceFinalToken1=9999999999999999999899999999698970967832658, balanceFinalToken2=9999999999999999999900000000301029032167343) (/Users/jocoders/Projects/Personal/RARE_SKILLS/hardhat-dex-problem-22/contracts/SetupContract.sol:194)

AssertionFailed(..): passing

Unique instructions: 6683
Unique codehashes: 3
Corpus size: 10
Seed: 2241052500702283332
```

INIT: 9999999999999999999900000000000000166175873 + 999999999999999999899999999999999833824127 = 1999999999999999999899999999999999850505254
FINAL:9999999999999999999899999999698970967832658 + 9999999999999999999900000000301029032167343 = 19999999999999999999899999999999999306216008

INIT lesser than FINAL, but why the condition is failed?
Condition: assert(finalBalance1 + finalBalance2 <= initBalance1 + initBalance2);
