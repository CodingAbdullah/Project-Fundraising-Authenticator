// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0;

contract Campaign {

	address manager;
	int contributorsCount = 0;

	// Provide a basic structure for each request to be created by manager

	struct Request {
		int approvalCount;
		string description;
		mapping(address => bool) approvals;
		address recipient;
		int value;
		bool isComplete;
	}

	mapping(address => bool) contributors;
	uint minimumContribution;
	Request[] requests;
	
	constructor(uint contribution) {
		manager = msg.sender;

		require(contribution > 0);
		minimumContribution = contribution; // Specify a minimum contributor
	}

	modifier restricted {
		require(msg.sender == manager); // Restrict some methods to manager capability
		_;
	}

	function contribute() external payable {
		require(msg.value > minimumContribution); // If contributor suceeds in minimum payment, add as contributor
		contributorsCount++;
		contributors[msg.sender] = true;
	}

	function createRequest(string memory description, address recipient, int value) external {
		mapping(address => bool) approvalMap; // FIX THIS LINE

		Request memory newRequest = Request(
			0,
			description,
			approvalMap,
			recipient,
			value,
			false
		);

		requests.push(newRequest); // Push requests to main list
	}

	function approveRequest(int index) external restricted {

		// Run checks to see if contributor exists and if so, only deposited 1 vote
		require(contributors[msg.sender]);
		require(!requests[index].approvals[msg.sender]);

		requests[index].approvalCount++;
		requests[index].approvals[msg.sender] = true; // Increase approval count and add them to the map of approvers
	}

	function finalizeRequest(int index) external restricted {

		// Add logic to check approval rate against number of contributors here..
		if (requests[index]){
			requests[index].isComplete = true;
		}

	}
}
