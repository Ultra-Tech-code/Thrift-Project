// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./Groupthrift.sol";
import "./Singlethrift.sol";


contract Thrift{

    address Admin;  

    event NewSingleCreated(address indexed owner, string indexed goalDescription, Singlethrift indexed Thriftaddress);
    event NewGroupCreated(address indexed owner, string indexed goalDescription, Groupthrift indexed Thriftaddress);
    event GoalUpdated(address indexed owner, uint256 indexed Thriftid, uint256 updateTime);


    Singlethrift[] allSingleThrift;
    Groupthrift[] allgroupthrift;

    mapping(address => Singlethrift[]) singleThriftCreated;
    mapping(address => Groupthrift[]) groupThriftCreated;

    constructor(){
        Admin = msg.sender;   
    }


    function createSingleThrift(IERC20 _currency, string memory _goalDescription,  uint256 _target, uint256 _duration, uint256 _startTime, uint256 _savingInterval) external returns(Singlethrift singlethrift){
        require(_duration > 0, "INVALID DURATION!!!");
        require(_target > 0, "INVALID TARGET!!!");
        singlethrift = new Singlethrift(msg.sender, address(this), _goalDescription, _target, _duration, _currency, _startTime, _savingInterval);
        allSingleThrift.push(singlethrift);
        singleThriftCreated[msg.sender].push(singlethrift);

       emit NewSingleCreated(msg.sender, _goalDescription, singlethrift);
    }


    function createGroupThrift(IERC20 _currency, uint256 members, address[] memory membersAddress, string memory goalDescription, uint256 _target, uint256 _duration, uint256 _startime, uint256 _savingInterval) external returns(Groupthrift groupThrift){
        require(members == membersAddress.length, "MEMBER MATCH!!!");
        uint256 duration = _duration + block.timestamp;
        groupThrift = new Groupthrift(msg.sender, address(this), goalDescription,  _target, duration, _currency, _startime,  members, membersAddress, _savingInterval);
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

    function withdrawFee(address _tokenAddress) external{
        require(msg.sender == Admin, "NOT ADMIN");
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable{}


}