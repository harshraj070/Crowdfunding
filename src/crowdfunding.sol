//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract crowdfunding {
    address public owner;

    mapping(uint256 => mapping(address => uint256)) public contributions;

    struct Campaign {
        address starter;
        string name;
        string description;
        uint256 goal;
        uint256 timestamp;
        uint256 fundsRaised;
        bool isActive;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not authorized");
        _;
    }

    Campaign[] public campaigns;

    function StartCampaign(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _timestamp
    ) public onlyOwner {
        campaigns.push(
            Campaign({
                starter: msg.sender,
                name: _name,
                description: _description,
                goal: _goal,
                timestamp: _timestamp,
                fundsRaised: 0,
                isActive: true
            })
        );
    }

    function contribute(uint256 campaignIndex, uint256 amount) public payable {
        Campaign storage campaign = campaigns[campaignIndex];
        require(campaign.isActive, "The campaign isn't active");
        require(msg.value > 0, "Contribution cannot be zero");
        require(
            campaign.goal - campaign.fundsRaised >= amount,
            "Your amount is exceeding the required limit"
        );

        campaign.fundsRaised += amount;
        contributions[campaignIndex][msg.sender] += msg.value;
    }

    function withdraw(uint256 campaignIndex) public payable {
        Campaign storage campaign = campaigns[campaignIndex];
        require(
            msg.sender == campaign.starter,
            "Only contract owner can withdraw"
        );
        require(campaign.isActive, "The campaign is not active");
        require(campaign.fundsRaised > campaign.goal, "target not achieved");
        campaign.isActive = false;
        payable(campaign.starter).transfer(campaign.fundsRaised);
    }

    function refund(uint256 campaignIndex) public payable {
        Campaign storage campaign = campaigns[campaignIndex];
        require(!campaign.isActive, "campaign is still active");
        require(
            block.timestamp > campaign.timestamp,
            "the deadline is not there yet"
        );
        require(
            campaign.fundsRaised < campaign.goal,
            "The goal has been reached"
        );

        uint256 contribution = contributions[campaignIndex][msg.sender];
        require(contribution > 0, "You have no contribution");

        payable(msg.sender).transfer(contribution);
    }

    function abort(uint256 campaignIndex) public onlyOwner {
        Campaign storage campaign = campaigns[campaignIndex];
        require(campaign.isActive, "Campaign is already inactive");
        campaign.isActive = false;
    }

    function getActiveCampaigns() public view returns (Campaign[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].isActive) {
                activeCount++;
            }
        }

        Campaign[] memory activeCampaigns = new Campaign[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].isActive) {
                activeCampaigns[index] = campaigns[i];
                index++;
            }
        }
        return activeCampaigns;
    }
}
