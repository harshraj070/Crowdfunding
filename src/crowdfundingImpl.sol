// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./crowdfunding.sol";

contract crowdfundingImpl is crowdfunding {
    constructor() {
        owner = msg.sender;
    }
}
