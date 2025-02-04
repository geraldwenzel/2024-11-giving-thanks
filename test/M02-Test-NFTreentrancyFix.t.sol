// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {GivingThanksSecure} from "../src/GivingThanksSecure.sol";
import {CharityRegistry} from "../src/CharityRegistry.sol";
import {MaliciousCharity} from "../src/MaliciousCharity.sol";

contract NftReentracy is Test {
    GivingThanksSecure public charityContract;
    CharityRegistry public registryContract;
    MaliciousCharity public maliciousCharity;
    address public admin;
    address public maliciousCharityAddress;
    address public donor;

    function setUp() public {
        // Initialize addresses
        admin = makeAddr("admin");
        // maliciousCharityAddress = makeAddr("charity");
        donor = makeAddr("donor");

        // Deploy the CharityRegistry contract as admin
        vm.prank(admin);
        registryContract = new CharityRegistry();

        // Deploy the GivingThanks contract with the registry address
        charityContract = new GivingThanksSecure(address(registryContract));
        vm.stopPrank();

        // Deploy the MaliciousCharity contract
        maliciousCharity = new MaliciousCharity(address(charityContract));

        // Register and verify the charity
        vm.prank(maliciousCharityAddress);
        registryContract.registerCharity(address(maliciousCharity));
        vm.stopPrank();

        vm.prank(admin);
        registryContract.verifyCharity(address(maliciousCharity));
        vm.stopPrank();
    }

    function testNftReentrancyFix() public {
        /**
         * @dev Demonstrates a reentrancy attack against GivingThanks.donate()
         */
        uint256 donationAmount = 1 ether;

        // show the number of tokens before the reentrancy attack
        console.log(
            "Token count before reentrancy attack: ",
            charityContract.tokenCounter()
        );
        console.log();

        // Fund the donor
        vm.deal(donor, 10 ether);

        // Donor donates to the charity
        vm.expectRevert(); // Expect revert due to reentrancy guard
        vm.prank(donor);
        charityContract.donate{value: donationAmount}(
            address(maliciousCharity)
        );
        vm.stopPrank();

        console.log();
        console.log(
            "Token count after reentrancy attack: ",
            charityContract.tokenCounter()
        );
    }
}
