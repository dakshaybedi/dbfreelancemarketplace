// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FreelanceMarketplace {
    address payable public owner;
    uint public freelancerCount = 0;
    uint public projectCount = 0;

    struct Freelancer {
        uint id;
        string name;
        string skills;
        uint hourlyRate;
        uint rating;
        uint totalEarned;
        address add;
    }

    struct Project {
        uint id;
        string title;
        string description;
        uint budget;
        uint deadline;
        address payable freelancer;
        uint freelancerId;
        address payable employer;
        bool completed;
        bool paid;
    }

    mapping(uint => Freelancer) public freelancers;
    mapping(uint => Project) public projects;
    mapping(address => bool) public hasFreelancerAccount;

    event FreelancerAdded(uint id, string name, string skills, uint hourlyRate);
    event ProjectAdded(uint id, string title, string description, uint budget, uint deadline);
    event FreelancerHired(uint projectId, uint freelancerId);
    event ProjectCompleted(uint projectId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    function addFreelancer(string memory _name, string memory _skills, uint _hourlyRate) public {
        require(!hasFreelancerAccount[msg.sender], "You already have a freelancer account.");
        freelancerCount++;
        freelancers[freelancerCount] = Freelancer(freelancerCount, _name, _skills, _hourlyRate, 0, 0, msg.sender);
        hasFreelancerAccount[msg.sender] = true;
        emit FreelancerAdded(freelancerCount, _name, _skills, _hourlyRate);
    }

    function addProject(string memory _title, string memory _description, uint _budget, uint _deadline) public {
        projectCount++;
        projects[projectCount] = Project(projectCount, _title, _description, _budget, _deadline, payable(address(0)), 0 ,payable(msg.sender), false, false);
        emit ProjectAdded(projectCount, _title, _description, _budget, _deadline);
    }

    function hireFreelancer(uint _projectId, uint _freelancerId) public payable {
        require(projects[_projectId].employer == msg.sender, "Only the project employer can hire a freelancer.");
        require(freelancers[_freelancerId].hourlyRate * 2 <= projects[_projectId].budget, "The freelancer's hourly rate is too high for this project budget.");

        projects[_projectId].freelancer = payable(address(freelancers[_freelancerId].add));
        projects[_projectId].freelancerId = freelancers[_freelancerId].id;


        emit FreelancerHired(_projectId, _freelancerId);
    }

    function completeProject(uint _projectId) public {
        require(projects[_projectId].freelancer == msg.sender, "Only the project freelancer can complete the project.");
        require(!projects[_projectId].completed, "The project has already been completed.");
        
        uint paymentAmount = projects[_projectId].budget;
        projects[_projectId].completed = true;
        projects[_projectId].paid = true;
        freelancers[projects[_projectId].freelancerId].totalEarned += paymentAmount;

        payable(msg.sender).transfer(paymentAmount);

        emit ProjectCompleted(_projectId);
    }
}