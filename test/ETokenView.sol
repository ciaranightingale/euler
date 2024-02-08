// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {EToken} from "../contracts/modules/EToken.sol";

contract ETokenView is EToken(keccak256("moduleGitCommit_")) {
    function getLastInterestAccumulatorUpdate(address eToken) public view returns (uint40) {
        return eTokenLookup[eToken].lastInterestAccumulatorUpdate;
    }

    function getUnderlyingDecimals(address eToken) public view returns (uint8) {
        return eTokenLookup[eToken].underlyingDecimals;
    }
    
    function getInterestRateModel(address eToken) public view returns (uint32) {
        return eTokenLookup[eToken].interestRateModel;
    }
    
    function getInterestRate(address eToken) public view returns (int96) {
        return eTokenLookup[eToken].interestRate;
    }
    
    function getReserveFee(address eToken) public view returns (uint32) {
        return eTokenLookup[eToken].reserveFee;
    }
    
    function getPricingType(address eToken) public view returns (uint16) {
        return eTokenLookup[eToken].pricingType;
    }
    
    function getPricingParameters(address eToken) public view returns (uint32) {
        return eTokenLookup[eToken].pricingParameters;
    }
    
    function getUnderlying(address eToken) public view returns (address) {
        return eTokenLookup[eToken].underlying;
    }
    
    function getReserveBalance(address eToken) public view returns (uint96) {
        return eTokenLookup[eToken].reserveBalance;
    }
    
    function getDTokenAddress(address eToken) public view returns (address) {
        return eTokenLookup[eToken].dTokenAddress;
    }
    
    function getTotalBalances(address eToken) public view returns (uint112) {
        return eTokenLookup[eToken].totalBalances;
    }
    
    function getTotalBorrows(address eToken) public view returns (uint144) {
        return eTokenLookup[eToken].totalBorrows;
    }
    
    function getInterestAccumulator(address eToken) public view returns (uint256) {
        return eTokenLookup[eToken].interestAccumulator;
    }
    
    function getUserAsset(address eToken, address user) public view returns (UserAsset memory) {
        return eTokenLookup[eToken].users[getSubAccount(user, 0)];
    }

    // mapping(address => mapping(address => uint)) eTokenAllowance;
    // mapping(address => mapping(address => uint)) dTokenAllowance;
}
