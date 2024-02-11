// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Storage} from "../../contracts/Storage.sol";
import {IRiskManager} from "../../contracts/IRiskManager.sol";

interface IMarkets {
    function activateMarket(address underlying) external returns (address);
    function activatePToken(address underlying) external returns (address);
    function eTokenToDToken(address eToken) external view returns (address dTokenAddr);
    function eTokenToUnderlying(address eToken) external view returns (address underlying);
    function enterMarket(uint256 subAccountId, address newMarket) external;
    function exitMarket(uint256 subAccountId, address oldMarket) external;
    function getEnteredMarkets(address account) external view returns (address[] memory);
    function getPricingConfig(address underlying)
        external
        view
        returns (uint16 pricingType, uint32 pricingParameters, address pricingForwarded);
    function interestAccumulator(address underlying) external view returns (uint256);
    function interestRate(address underlying) external view returns (int96);
    function interestRateModel(address underlying) external view returns (uint256);
    function moduleGitCommit() external view returns (bytes32);
    function moduleId() external view returns (uint256);
    function reserveFee(address underlying) external view returns (uint32);
    function underlyingToAssetConfig(address underlying) external view returns (Storage.AssetConfig memory);
    function underlyingToAssetConfigUnresolved(address underlying) external view returns (Storage.AssetConfig memory config);
    function underlyingToDToken(address underlying) external view returns (address);
    function underlyingToEToken(address underlying) external view returns (address);
    function underlyingToPToken(address underlying) external view returns (address);

    function getLastInterestAccumulatorUpdate(string calldata message, address eToken) external view returns (uint40);
    function getUnderlyingDecimals(address eToken) external view returns (uint8);
    function getInterestRateModel(string calldata message, address eToken) external view returns (uint32);
    function getInterestRate(string calldata message, address eToken) external view returns (int96);
    function getReserveFee(string calldata message, address eToken) external view returns (uint32);
    function getPricingType(string calldata message, address eToken) external view returns (uint16);
    function getPricingParameters(string calldata message, address eToken) external view returns (uint32);
    function getUnderlying(string calldata message, address eToken) external view returns (address);
    function getReserveBalance(string calldata message, address eToken) external view returns (uint96);
    function getDTokenAddress(string calldata message, address eToken) external view returns (address);
    function getTotalBalances(string calldata message, address eToken) external view returns (uint112);
    function getTotalBorrows(string calldata message, address eToken) external view returns (uint144);
    function getInterestAccumulator(string calldata message, address eToken) external view returns (uint256);
    function getUserAsset(string calldata message, address eToken, address user) external view returns (Storage.UserAsset memory);
    function getLiquidityStatus(address account) external returns (IRiskManager.LiquidityStatus memory);
}