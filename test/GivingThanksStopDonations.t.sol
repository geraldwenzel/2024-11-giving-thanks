// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/GivingThanks.sol";
import "../src/CharityRegistry.sol";
import {BadCharityRegistry} from "../src/CharityRegistryStopDonations.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract GivingThanksTest is Test {
    GivingThanks public charityContract;
    CharityRegistry public registryContract;
    BadCharityRegistry public badRegistryContract;
    address public admin;
    address public charity;
    address public donor;

    function setUp() public {
        // Initialize addresses
        admin = makeAddr("admin");
        charity = makeAddr("charity");
        donor = makeAddr("donor");

        // Deploy the CharityRegistry contract as admin
        vm.prank(admin);
        registryContract = new CharityRegistry();

        // Deploy the BadCharityRegistry contract as admin
        vm.prank(admin);
        badRegistryContract = new BadCharityRegistry();

        // Deploy the GivingThanks contract with the registry address
        vm.prank(admin);
        charityContract = new GivingThanks(address(registryContract));

        // Register and verify the charity
        vm.prank(charity);
        registryContract.registerCharity(charity);

        vm.prank(admin);
        registryContract.verifyCharity(charity);
    }

    function testStopDonatations() public {
        uint256 donationAmount = 1 ether;

        // update the registry to the bad registry
        charityContract.updateRegistry(address(badRegistryContract));

        // Fund the donor
        vm.deal(donor, 10 ether);

        // Donor donates to the charity
        vm.prank(donor);
        // Donation should fail because the charity is not verified
        vm.expectRevert();
        charityContract.donate{value: donationAmount}(charity);

    }
}
