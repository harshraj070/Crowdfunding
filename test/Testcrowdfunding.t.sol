//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {crowdfundingImpl} from "../src/crowdfundingImpl.sol";

contract TestCrowdfunding is Test {
    crowdfundingImpl public crowdfunding;

    address owner = address(1);
    address contributor1 = address(2);
    address contributor2 = address(3);

    function setUp() public {
        vm.prank(owner);
        crowdfunding = new crowdfundingImpl();
    }

    function testStartcampaign() public {
        vm.prank(owner);
        crowdfunding.StartCampaign(
            "save the forests",
            "this campaign is to save forests",
            10 ether,
            block.timestamp + 1 days
        );

        //check if the campaign was started
        (
            address starter,
            string memory name,
            ,
            uint256 goal,
            ,
            ,
            bool isActive
        ) = crowdfunding.campaigns(0);
        assertEq(starter, owner);
        assertEq(name, "save the forests");
        assertEq(goal, 10 ether);
        assertTrue(isActive);
    }

    function testContribution() public {
        vm.prank(owner);
        crowdfunding.StartCampaign(
            "save the trees",
            "starting a fundraiser to save trees",
            10 ether,
            block.timestamp + 1 days
        );

        //contribute to the campaign
        vm.deal(contributor1, 10 ether);
        vm.prank(contributor1);
        crowdfunding.contribute{value: 5 ether}(0, 5 ether);
        (, , , , , uint256 fundsRaised, ) = crowdfunding.campaigns(0);
        assertEq(fundsRaised, 5 ether);
        //assertEq(crowdfunding.contributions(0, contributor1), 5 ether);
    }

    function testWithdraw() public {
        vm.prank(owner);
        crowdfunding.StartCampaign(
            "Save the Forests",
            "A campaign to save forests",
            5 ether,
            block.timestamp + 1 days
        );

        vm.deal(contributor1, 10 ether);
        vm.prank(contributor1);
        crowdfunding.contribute{value: 5 ether}(0, 5 ether);

        //withdraw funds as the campaign starter
        vm.prank(owner);
        crowdfunding.withdraw(0);

        //check is the campaign is deactivated
        (, , , , , , bool isActive) = crowdfunding.campaigns(0);
        assertFalse(isActive);
    }

    function testRefund() public {
        vm.prank(owner);
        crowdfunding.StartCampaign(
            "Save the Forests",
            "A campaign to save forests",
            10 ether,
            block.timestamp + 1 days
        );

        vm.deal(contributor1, 10 ether);
        vm.prank(contributor1);
        crowdfunding.contribute{value: 5 ether}(0, 5 ether);

        vm.warp(block.timestamp + 2 days); // Fast forward time
        vm.prank(owner);
        crowdfunding.abort(0); // Abort the campaign

        vm.prank(contributor1);
        crowdfunding.refund(0);

        // Verify refund
        assertEq(crowdfunding.contributions(0, contributor1), 0);
    }
}
