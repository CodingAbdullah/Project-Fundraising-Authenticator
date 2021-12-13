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

	function createRequest(string memory desc, address r, int val) external restricted {

		Request memory newRequest = Request(
			0,
			desc,
			r,
			val,
			false
		);

		requests.push(newRequest); // Push requests to main list
	}

	function approveRequest(int index) external {

		// Run checks to see if contributor exists and if so, only deposited 1 vote
		require(contributors[msg.sender]);
		require(!requests[index].approvals[msg.sender]);

		requests[index].approvalCount++;
		requests[index].approvals[msg.sender] = true; // Increase approval count and add them to the map of approvers
	}

	function finalizeRequest(int index) external restricted {
		require(!requests[index]); // If the request was approved, no need to proceed

		/* 	
			*** --- READ ME --- ***
			Division of fractions not possible in solidity. So a workaround to check if 50% 
			of approvals were received, I inverted the operation by dividing the total number of contributors 
			by the number of approvals. The number should be 2 or less than 2 (inverse of 1/2 is 2).
			
			In order to make sure it is exactly 50% (or in this case, the inverse is exactly 2) make
			sure the remainder from the inverse division operation equates to 0. 
			
			Solidity fails with modulo operations. So I ran a test to see if I subtract 
			the remainder value from any count (approval/contributor any would work), I should return 
			the count itself as subtracting 0 from anything does not change value. 
			
			Complex work around for not being able to do decimal division to check 50% of voters 
			or the modulo division.

			It is what it is. If you know Math, you know ;)
		*/

		int remainder = contributorsCount % requests[index].approvalCount;
		require(contributorsCount / requests[index].approvalCount <= 2);
		require(requests[index].approvalCount - remainder == 0);


		// If the checks pass, change approval status of given request to true. 
		if (requests[index]) {
			requests[index].isComplete = true;
		}
	}
}