// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./IERC20.sol";


contract Singlethrift {
    address owner;

    struct Account {
        address accountOwner;
        address thriftAddress;
        string goalDescription;
        uint256 target;
        uint256 duration;
        IERC20 currency;
        uint256 startTime;
        uint256 endTime;
        uint256 amountContributed;
        bool goalStatus;
    }

    event NewGoalCreated(address indexed owner, string indexed goalDescription, uint256 indexed Thriftid);
    event GoalUpdated(address indexed owner, uint256 indexed Thriftid, uint256 updateTime);

    error NotGoal();
    error NotDeadline();

    modifier onlyOwner(){
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    mapping(address => Account) accounts;

    constructor (address _owner, address _thriftAddress, string memory _goalDescription, uint256 _target, uint256 _duration, IERC20 _currency, uint256 _startTime ){
        owner = _owner;
        accounts[_owner]= Account({
            accountOwner: _owner,
            thriftAddress: _thriftAddress,
            goalDescription: _goalDescription,
            target: _target,
            duration: _duration,
            currency: _currency,
            startTime: _startTime,
            endTime: block.timestamp + _duration,
            amountContributed: 0,
            goalStatus: false 
        });

    }


    function editGoal(address _owner) external {

       // emit GoalUpdated()

    }

    function save(address _owner, uint256 _amount) external {
        Account memory account = accounts[_owner];
        require(!account.goalStatus, "TARGET REACHED");
        require(account.currency.transfer(address(this), _amount*1e18), "FAILED!!");

        if(account.amountContributed + _amount >= account.target ){
            accounts[_owner].goalStatus = true;
        }
        accounts[_owner].amountContributed += _amount;
    }

    function withdraw(address _owner) external {
        Account memory account = accounts[_owner];
        require(account.amountContributed > 0, "NO FUNDS!!");
        if(!account.goalStatus ){
            revert NotGoal(); 
        }
        if(account.endTime > block.timestamp){
            revert NotDeadline();
        }

        accounts[_owner].amountContributed = 0;
    }

    function getGoal() external {

    }

    function emergencyWithdrawal() external {
        //check if amount saved is not less than the penalty fee
    }

    function getAmountSaved(address _owner) view external returns(uint256){
        return accounts[_owner].amountContributed;

    } 

    function getDeadline(address _owner) view external returns(uint256){
        return accounts[_owner].endTime;

    }

    function getTarget(address _owner) view external returns(uint256){
        return accounts[_owner].target;

    }

    function getuserAccount(address _owner) view external returns(Account memory){
        return accounts[_owner];    
    }

    function getDescription(address _owner) view external returns(string memory){
        return accounts[_owner].goalDescription;
    }


}