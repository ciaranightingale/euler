// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {Markets} from "../contracts/modules/Markets.sol";
import {IRiskManager} from "../contracts/IRiskManager.sol";
import "forge-std/src/Test.sol";

contract MarketsView is Markets(keccak256("moduleGitCommit_")) {
    function getLastInterestAccumulatorUpdate(string calldata message, address eToken) public view returns (uint40) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].lastInterestAccumulatorUpdate);
        return eTokenLookup[eToken].lastInterestAccumulatorUpdate;
    }

    function getUnderlyingDecimals(string calldata message, address eToken) public view returns (uint8) {
        return eTokenLookup[eToken].underlyingDecimals;
    }

    function getInterestRateModel(string calldata message, address eToken) public view returns (uint32) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].interestRateModel);
        return eTokenLookup[eToken].interestRateModel;
    }

    function getInterestRate(string memory message, address eToken) public view returns (int96) {
        console.log(message);
        console.logInt(eTokenLookup[eToken].interestRate);
        return eTokenLookup[eToken].interestRate;
    }

    function getReserveFee(string calldata message, address eToken) public view returns (uint32) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].reserveFee);
        return eTokenLookup[eToken].reserveFee;
    }

    function getPricingType(string calldata message, address eToken) public view returns (uint16) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].pricingType);
        return eTokenLookup[eToken].pricingType;
    }

    function getPricingParameters(string calldata message, address eToken) public view returns (uint32) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].pricingParameters);
        return eTokenLookup[eToken].pricingParameters;
    }

    function getUnderlying(string calldata message, address eToken) public view returns (address) {
        console.log(message);
        console.log(message, eTokenLookup[eToken].underlying);
        return eTokenLookup[eToken].underlying;
    }

    function getReserveBalance(string calldata message, address eToken) public view returns (uint96) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].reserveBalance);
        return eTokenLookup[eToken].reserveBalance;
    }

    function getDTokenAddress(string calldata message, address eToken) public view returns (address) {
        console.log(message);
        console.log(eTokenLookup[eToken].dTokenAddress);
        return eTokenLookup[eToken].dTokenAddress;
    }

    function getTotalBalances(string calldata message, address eToken) public view returns (uint112) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].totalBalances);
        return eTokenLookup[eToken].totalBalances;
    }

    function getTotalBorrows(string calldata message, address eToken) public view returns (uint144) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].totalBorrows);
        return eTokenLookup[eToken].totalBorrows;
    }

    function getInterestAccumulator(string calldata message, address eToken) public view returns (uint256) {
        console.log(message);
        console.logUint(eTokenLookup[eToken].interestAccumulator);
        return eTokenLookup[eToken].interestAccumulator;
    }

    function getUserAsset(string calldata message, address eToken, address user)
        public
        view
        returns (UserAsset memory)
    {
        console.log(message);
        console.logUint(eTokenLookup[eToken].users[getSubAccount(user, 0)].balance);
        console.logUint(eTokenLookup[eToken].users[getSubAccount(user, 0)].owed/1e9);
        return eTokenLookup[eToken].users[getSubAccount(user, 0)];
    }


    function getLiquidityStatus(address account) public returns (IRiskManager.LiquidityStatus memory status) {
        bytes memory result = callInternalModule(
            MODULEID__RISK_MANAGER, abi.encodeWithSelector(IRiskManager.computeLiquidity.selector, account)
        );
        (status) = abi.decode(result, (IRiskManager.LiquidityStatus));
    }

    // mapping(address => mapping(address => uint)) eTokenAllowance;
    // mapping(address => mapping(address => uint)) dTokenAllowance;
}
