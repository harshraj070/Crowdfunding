//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {crowdfundingImpl} from "../src/crowdfundingImpl.sol";

contract DeployCrowdfunding is Script {
    function run() external {
        vm.startBroadcast();
        crowdfundingImpl concreteCrowdfunding = new crowdfundingImpl();
        vm.stopBroadcast();
    }
}
