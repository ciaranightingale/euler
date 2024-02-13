// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Storage} from "euler-contracts/contracts/Storage.sol";

interface IEToken {
    function deposit(uint256 subAccountId, uint256 amount) external;
    function mint(uint256 subAccountId, uint256 amount) external;
    function donateToReserves(uint256 subAccountId, uint256 amount) external;
    function withdraw(uint256 subAccountId, uint256 amount) external;
}