// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IDToken {
    function repay(uint256 subAccountId, uint256 amount) external;
}