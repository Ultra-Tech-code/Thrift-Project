// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./Jointthrift.sol";
import "./Singlethrift.sol";


contract Thrift{

    struct account {
        address accountOwner;
        string goalDescription;
        uint256 target;
    }

    event NewGoalCreated(address indexed owner, string indexed goalDescription, Singlethrift indexed Thriftaddress);
    event GoalUpdated(address indexed owner, uint256 indexed Thriftid, uint256 updateTime);


    Singlethrift[] allSingleThrift;
    Jointthrift[] alljointThrift;

    mapping(address => Singlethrift[]) singleThriftCreated;
    mapping(address => Jointthrift[]) jointThriftCreated;



    function singleContribution(IERC20 _currency, string memory _goalDescription,  uint256 _target, uint256 _duration, uint256 _startTime) external returns(Singlethrift singlethrift){
        singlethrift = new Singlethrift(msg.sender, address(this), _goalDescription, _target, _duration, _currency, _startTime);
        allSingleThrift.push(singlethrift);
        singleThriftCreated[msg.sender].push(singlethrift);

       emit NewGoalCreated(msg.sender, _goalDescription, singlethrift);

       return singlethrift;
    }


    function jointContribution (IERC20 _currency, uint256 members, address[] memory membersAddress, string memory goalDescription, uint256 _target, uint256 _duration) external{
        require(members == membersAddress.length, "MATCH!!!");
        uint256 duration = _duration + block.timestamp;
        Jointthrift jointThrift = new Jointthrift(msg.sender, address(this), goalDescription,  _target, duration, _currency,  members, membersAddress);
        alljointThrift.push(jointThrift);
        jointThriftCreated[msg.sender].push(jointThrift);

    }

    function allSingle() external view returns(Singlethrift[] memory){
        return allSingleThrift;
    }

    function allJoint() external view returns(Jointthrift[] memory){
        return alljointThrift;
    }

    function userSingleThrift(address owner) external view returns (Singlethrift[] memory){
        return singleThriftCreated[owner];
    }

    function userGroupThrift(address owner) external view returns (Jointthrift[] memory){
        return jointThriftCreated[owner];
    }


}