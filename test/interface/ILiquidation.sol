// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ILiquidation {
    struct LiquidationOpportunity {
        uint256 repay;
        uint256 yield;
        uint256 healthScore;
        uint256 baseDiscount;
        uint256 discount;
        uint256 conversionRate;
    }

    function liquidate(
        address violator,
        address underlying,
        address collateral,
        uint256 repay,
        uint256 minYield
    ) external;
    function checkLiquidation(
        address liquidator,
        address violator,
        address underlying,
        address collateral
    ) external returns (LiquidationOpportunity memory liqOpp);
}