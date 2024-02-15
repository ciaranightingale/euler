// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { IERC20 } from "forge-std/src/interfaces/IERC20.sol";
import { IEToken } from "./interface/IEToken.sol";
import { IDToken } from "./interface/IDToken.sol";
import { ILiquidation } from "./interface/ILiquidation.sol";
import { IMarkets } from "./interface/IMarkets.sol";

import "forge-std/src/Test.sol";

contract Liquidator {
    IERC20 immutable UNDERLYING;
    IEToken immutable eToken;
    IDToken immutable dToken;
    address immutable EULER;
    ILiquidation immutable LIQUIDATION;
    IMarkets immutable MARKETS;

    event log_named_decimal_uint (string key, uint val, uint decimals);

    constructor(IERC20 _underlying, IEToken _eToken, IDToken _dToken, address _euler, ILiquidation _liquidation, IMarkets _markets) {
        UNDERLYING = _underlying;
        eToken = _eToken;
        dToken = _dToken;
        EULER = _euler;
        LIQUIDATION = _liquidation;
        MARKETS = _markets;
    }


    function liquidate(address violator) external {
        //9. Liquidate violator's account
        ILiquidation.LiquidationOpportunity memory returnData =
            LIQUIDATION.checkLiquidation(address(this), violator, address(UNDERLYING), address(UNDERLYING));

        LIQUIDATION.liquidate(violator, address(UNDERLYING), address(UNDERLYING), returnData.repay, returnData.yield);
        MARKETS.getUserAsset("After liquidating (liquidator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(this));
        console.log(" ");
        MARKETS.getUserAsset("After liquidating (violator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(violator));
        console.log("EULER balance", UNDERLYING.balanceOf(EULER) / 1e18, IERC20(UNDERLYING).symbol());
        console.log(" ");

        // 10. Withdraw contract balance
        eToken.withdraw(0, UNDERLYING.balanceOf(EULER));
        MARKETS.getUserAsset("After withdrawing (liquidator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(this));
        console.log("EULER balance", UNDERLYING.balanceOf(EULER) / 1e18, IERC20(UNDERLYING).symbol());
        console.log(" ");

        // Send the funds back to the address that took the flash loan for repayment
        UNDERLYING.transfer(msg.sender, UNDERLYING.balanceOf(address(this)));
    }
}