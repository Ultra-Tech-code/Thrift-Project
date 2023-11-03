// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;


// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Thrift {
    // struct GroupContribution {
    //     address payable contributor;
    //     uint256 amount;
    //     uint256 nonce;
    //     uint256 unlockTime;
    // }

    // struct JointContribution {
    //     address payable contributor;
    //     uint256 amount;
    //     uint256 nonce;
    //     uint256 unlockTime;
    // }

    // struct Transaction {
    //     address payable to;
    //     uint256 amount;
    //     uint256 nonce;
    // }
    
    
    //group contribution
    //Joint contribution

    struct Contribution {
        address contributor;
        string goalDescription;
        uint256 target;
        uint256 duration;
        uint256 startTime;
        uint256 endTime;
        uint256 amountContributed;
        bool goalStatus;
    }

    mapping(address => Contribution[]) public contributions;

    modifier goalExists(uint256 _goalId, address _goalCreator) {
        require(_goalId < contributions[_goalCreator].length, "Goal does not exist");
        _;
    }

    modifier goalNotCompleted(uint256 _goalId, address _goalCreator) {
        require(contributions[_goalCreator][_goalId].goalStatus == false, "Goal has already been completed");
        _;
    }

    modifier validString(string memory _string) {
        require(bytes(_string).length > 0, "String must not be empty");
        _;
    }


    function createGoal(string memory goalDescription, uint256 target, uint256 duration) public validString(goalDescription) {
        require(duration > 0 && target > 0, "Duration/target must be greater than 0");

        contributions[msg.sender].push(Contribution(msg.sender, goalDescription, target, duration, block.timestamp, block.timestamp + duration, 0, false));

    }



    function completeGoal(uint256 _goalId, address _goalCreator) public goalExists(_goalId, _goalCreator) goalNotCompleted(_goalId, _goalCreator) {
        require(contributions[_goalCreator][_goalId].target <= address(this).balance, "Goal has not been met");

        contributions[_goalCreator][_goalId].goalStatus = true;
        payable(_goalCreator).transfer(contributions[_goalCreator][_goalId].target);
    }
    





    function getContribution() public view returns (Contribution[] memory) {
        return contributions[msg.sender];
    }




}