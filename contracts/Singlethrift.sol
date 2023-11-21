// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
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
        uint256 savingInterval;
        bool goalStatus;
        bool canceled;
    }

    error Goal(string);
    error Deadline(string);
    error Owner(string);
    error Amount(string);
    error Deleted(string);
    error Start(string, uint256);
    error PaymentCycle(string);

    modifier onlyOwner(){
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    mapping(uint256 => bool) paid;

    Account account;

    constructor (address _owner, address _thriftAddress, string memory _goalDescription, uint256 _target, uint256 _duration, IERC20 _currency, uint256 _startTime, uint256 _savingInterval ){
        owner = _owner;
        _startTime += block.timestamp;
        account = Account({
            accountOwner: _owner,
            thriftAddress: _thriftAddress,
            goalDescription: _goalDescription,
            target: _target,
            duration: _duration,
            currency: _currency,
            startTime: _startTime,
            endTime: _duration + _startTime,
            amountContributed: 0,
            savingInterval: _savingInterval,
            goalStatus: false,
            canceled: false
        });

        emit NewGoalCreated(_owner, _goalDescription, _target);
    }


    function editGoal() external {

       // emit GoalUpdated()

    }

    function save() external {
        if(account.startTime >= block.timestamp){
            revert Start("Can't save yet!!", account.startTime);
        }

        uint256 elapsedTime = block.timestamp - account.startTime;
    
        // Calculate the current cycle based on the elapsed time since the start
        uint256 currentCycle = elapsedTime / account.savingInterval;

        uint256 _amount = amountToSavePerInterval();

        // Check if the user has already made a payment in the current cycle
        if(paid[currentCycle] == true){
            revert PaymentCycle(" WAIT FOR NEXT PAYMENT CYCLE!!");
        }
        if(account.canceled){
            revert Deleted("ACCOUNT Deleted!!");
         }
        if(_amount < 0){
            revert Amount("INVALID AMOUNT!!");
        }
        if(account.goalStatus){
            revert Goal("TARGET REACHED!!!"); 
        }
        if(account.endTime <= block.timestamp){
            revert Deadline("DEADLINE PASSED!!");
        }
        require(account.currency.transferFrom(msg.sender, address(this), _amount), "FAILED!!");

        if(account.amountContributed + _amount >= account.target ){
            account.goalStatus = true;
        }
        account.amountContributed += _amount;
        paid[currentCycle] = true;

        emit NewSave(msg.sender, _amount, block.timestamp);
    }

    function withdraw() external {
        uint256 amount = account.amountContributed;
        if(account.canceled){
            revert Deleted("ACCOUNT Deleted!!");
         }
        if(account.amountContributed <= 0){
            revert Amount("NO FUNDS!!!!");
        }
        address _owner = account.accountOwner;
        if(msg.sender != _owner){
            revert Owner("NOT OWNER!!");
         }
        if(account.endTime > block.timestamp){
            revert Deadline("DEADLINE NOT REACHED!!");
        }
        if(account.endTime < block.timestamp && !account.goalStatus){
            uint256 _penaltyfee = amount * 2 / 100;
            uint256 _amount = amount - _penaltyfee;
            account.amountContributed = 0;
            require(account.currency.transfer(_owner, _amount), "FAILED!!");
            require(account.currency.transfer(account.thriftAddress, _penaltyfee), "FAILED!!");
        }else{
            account.amountContributed = 0;
            require(account.currency.transfer(_owner, amount), "FAILED!!");
        }
        emit NewWithdraw(msg.sender, amount, block.timestamp);
    }

    function getGoalStatus() external view returns(bool){
        return account.goalStatus;

    }

    function emergencyWithdrawal() external {
        address _owner = account.accountOwner;
        if(msg.sender != _owner){
            revert Owner("NOT OWNER!!");
         }
         if(account.canceled){
            revert Deleted("ACCOUNT Deleted!!");
         }
         if(account.goalStatus){
            revert Goal("TARGET REACHED!!!");
         }
         if(account.amountContributed <= 0){
            account.canceled = true;
        }else{
            uint256 amountSaved = account.amountContributed;
            account.amountContributed = 0;
            uint256 penaltyfee = amountSaved * 2 / 100;
            uint256 amount = amountSaved - penaltyfee;
            require(account.currency.transfer(account.thriftAddress, penaltyfee), "FAILED!!");
            require(account.currency.transfer(_owner, amount), "FAILED!!");
            account.canceled = true;
        }
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

    function calculateTimeLeft() view external returns(uint256){
        return account.endTime - block.timestamp;
    }

    function amountToSavePerInterval() view public returns(uint256){
        return account.target / (account.duration / account.savingInterval);
    }


}
