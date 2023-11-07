// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./Groupthrift.sol";
import "./Singlethrift.sol";


contract Thrift{

    struct account {
        address accountOwner;
        string goalDescription;
        uint256 target;
    }

    event NewSingleCreated(address indexed owner, string indexed goalDescription, Singlethrift indexed Thriftaddress);
    event NewGroupCreated(address indexed owner, string indexed goalDescription, Groupthrift indexed Thriftaddress);
    event GoalUpdated(address indexed owner, uint256 indexed Thriftid, uint256 updateTime);


    Singlethrift[] allSingleThrift;
    Groupthrift[] allgroupthrift;

    mapping(address => Singlethrift[]) singleThriftCreated;
    mapping(address => Groupthrift[]) groupThriftCreated;



    function createSingleThrift(IERC20 _currency, string memory _goalDescription,  uint256 _target, uint256 _duration, uint256 _startTime) external returns(Singlethrift singlethrift){
        singlethrift = new Singlethrift(msg.sender, address(this), _goalDescription, _target, _duration, _currency, _startTime);
        allSingleThrift.push(singlethrift);
        singleThriftCreated[msg.sender].push(singlethrift);

       emit NewSingleCreated(msg.sender, _goalDescription, singlethrift);
    }


    function createGroupThrift(IERC20 _currency, uint256 members, address[] memory membersAddress, string memory goalDescription, uint256 _target, uint256 _duration, uint256 _startime) external returns(Groupthrift groupThrift){
        require(members == membersAddress.length, "NOT MATCH!!!");
        uint256 duration = _duration + block.timestamp;
        groupThrift = new Groupthrift(msg.sender, address(this), goalDescription,  _target, duration, _currency, _startime,  members, membersAddress);
        allgroupthrift.push(groupThrift);
        groupThriftCreated[msg.sender].push(groupThrift);

        emit NewGroupCreated(msg.sender, goalDescription, groupThrift);

    }

    function allSingle() external view returns(Singlethrift[] memory){
        return allSingleThrift;
    }

    function allGroup() external view returns(Groupthrift[] memory){
        return allgroupthrift;
    }

    function userSingleThrift(address owner) external view returns (Singlethrift[] memory){
        return singleThriftCreated[owner];
    }

    function userGroupThrift(address owner) external view returns (Groupthrift[] memory){
        return groupThriftCreated[owner];
    }


}