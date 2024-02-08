// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Storage} from "../../contracts/Storage.sol";

interface IEToken {
    function deposit(uint256 subAccountId, uint256 amount) external;
    function mint(uint256 subAccountId, uint256 amount) external;
    function donateToReserves(uint256 subAccountId, uint256 amount) external;
    function withdraw(uint256 subAccountId, uint256 amount) external;
    function getLastInterestAccumulatorUpdate(address eToken) external view returns (uint40);
    function getUnderlyingDecimals(address eToken) external view returns (uint8);
    function getInterestRateModel(address eToken) external view returns (uint32);
    function getInterestRate(address eToken) external view returns (int96);
    function getReserveFee(address eToken) external view returns (uint32);
    function getPricingType(address eToken) external view returns (uint16);
    function getPricingParameters(address eToken) external view returns (uint32);
    function getUnderlying(address eToken) external view returns (address);
    function getReserveBalance(address eToken) external view returns (uint96);
    function getDTokenAddress(address eToken) external view returns (address);
    function getTotalBalances(address eToken) external view returns (uint112);
    function getTotalBorrows(address eToken) external view returns (uint144);
    function getInterestAccumulator(address eToken) external view returns (uint256);
    function getUserAsset(address eToken, address user) external view returns (Storage.UserAsset memory);
}