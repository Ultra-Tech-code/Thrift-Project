// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./IERC20.sol";


contract Singlethrift {
    address owner;

    event NewGoalCreated(address indexed owner, string indexed goalDescription, uint256 indexed Thriftid);
    event GoalUpdated(address indexed owner, uint256 indexed Thriftid, uint256 updateTime);
    event NewSave(address indexed saver, uint256 indexed target, uint256 indexed time);
    event NewWithdraw(address indexed owner, uint256 indexed amount, uint256 indexed time);

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

    error Goal(string);
    error Deadline(string);
    error Owner(string);
    error Amount(string);

    modifier onlyOwner(){
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    // mapping(address => Account) accounts;
    Account account;

    constructor (address _owner, address _thriftAddress, string memory _goalDescription, uint256 _target, uint256 _duration, IERC20 _currency, uint256 _startTime ){
        owner = _owner;
        account = Account({
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

        emit NewGoalCreated(_owner, _goalDescription, _target);
    }


    function editGoal(address _owner) external {

       // emit GoalUpdated()

    }

    function save(uint256 _amount) external {
        if(_amount <= 0){
            revert Amount("INVALID AMOUNT!!");
        }
        if(account.goalStatus){
            revert Goal("TARGET REACHED!!!"); 
        }
        if(account.endTime <= block.timestamp){
            revert Deadline("DEADLINE PASSED!!");
        }
        require(account.currency.transfer(address(this), _amount), "FAILED!!");

        if(account.amountContributed + _amount >= account.target ){
            account.goalStatus = true;
        }
        account.amountContributed += _amount;

        emit NewSave(msg.sender, _amount, block.timestamp);
    }

    function withdraw() external {
        if(account.amountContributed <= 0){
            revert Amount("NO FUNDS!!!!");
        }
        address _owner = account.accountOwner;
        if(msg.sender != _owner){
            revert Owner("NOT OWNER!!");
         }
        if(!account.goalStatus){
            //revert Goal("TARGET NOT REACHED!!!");
            //penalty fee
        }
        if(account.endTime > block.timestamp){
            revert Deadline("DEADLINE NOT REACHED!!");
        }
        uint256 amount = account.amountContributed;
        account.amountContributed = 0;
        require(account.currency.transferFrom(address(this), _owner, amount), "FAILED!!");

        emit NewWithdraw(msg.sender, amount, block.timestamp);
    }

    function getGoal() external {

    }

    function emergencyWithdrawal() external {
        //check if amount saved is not less than the penalty fee
    }

    function getAmountSaved() view external returns(uint256){
        return account.amountContributed;

    } 

    function getDeadline() view external returns(uint256){
        return account.endTime;

    }

    function getTarget() view external returns(uint256){
        return account.target;

    }

    function getAccount() view external returns(Account memory){
        return account;    
    }

    function getDescription() view external returns(string memory){
        return account.goalDescription;
    }


}