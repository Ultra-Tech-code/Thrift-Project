// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "./IERC20.sol";

contract Groupthrift {
    uint256 memberId;

    event NewGoalCreated(address indexed owner, string indexed goalDescription, uint256 indexed target);
    event GoalUpdated(address indexed owner, uint256 indexed Thriftid, uint256 updateTime);
    event NewSave(address indexed owner, uint256 indexed target, uint256 indexed time);
    event NewWithdraw(address indexed owner, uint256 indexed amount, uint256 indexed time);

    struct Account {
        address owner;
        address thriftAddress;
        string goalDescription;
        uint256 target;
        uint256 duration;
        IERC20 currency;
        uint256 startTime;
        uint256 endTime;
        uint256 members;
        address[] membersAddress;
        uint256 savingInterval;
        uint256 amountContributed;
        bool goalStatus;
       
    }

    struct userAccount{
        address ownerAddress;
        bool goalStatus;
        uint256 amountContributed;
        bool withdraw;
        bool canceled;
    }

    error Goal(string);
    error Deadline(string);
    error Owner(string);
    error Amount(string);
    error Deleted(string);
    error Start(string, uint256);
    error PaymentCycle(string);



    // mapping(address => Account) usersaccount;
    mapping(address => uint256) saved;
    mapping(address => bool) isValid;
    mapping(address => userAccount) usersaccount;
    mapping(address => mapping(uint256 => bool)) paid;

    modifier validMember(address _member){
        require(isValid[_member] == true, "NOT MEMBER!!");
        _;
    }

    Account account;

    constructor (address _owner,address _thriftAddress, string memory _goalDescription, uint256 _target, uint256 _duration, IERC20 _currency, uint256 _startTime, uint256 _members, address[] memory _membersAddress, uint256 _savingInterval) {
            for (uint i = 0; i < _members; i++) {
               address member = _membersAddress[i];

                require(member != address(0), "INVALID!!!");
                isValid[member] = true;
            }

            _startTime += block.timestamp;

            account = Account({
                owner: _owner,
                thriftAddress: _thriftAddress,
                goalDescription: _goalDescription,
                target: _target,
                duration: _duration,
                currency: _currency,
                startTime: _startTime,
                endTime: _duration + _startTime,
                members: _members,
                membersAddress: _membersAddress,
                savingInterval: _savingInterval,
                amountContributed: 0,
                goalStatus: false
            });

            emit NewGoalCreated(_owner, _goalDescription, _target);
    }

    function editGoal(address _owner) external {

       // emit GoalUpdated()

    }

    function save(address _member) external validMember(_member) {
        userAccount memory USA = usersaccount[_member];
        if(account.startTime >= block.timestamp){
            revert Start("Can't save yet!!", account.startTime);
        }

        uint256 _amount = amountToSavePerInterval();

        // Check if the user has already made a payment in the current cycle
        if(paid[_member][getCycle()] == true){
            revert PaymentCycle(" WAIT FOR NEXT PAYMENT CYCLE!!");
        }
        if(USA.canceled){
            revert Deleted("ACCOUNT Deleted!!");
         }
         if(_amount < 0){
            revert Amount("INVALID AMOUNT!!");
        }
        if(USA.goalStatus ){
            revert Goal("TARGET REACHED!!!"); 
        }
        if(account.endTime <= block.timestamp){
            revert Deadline("DEADLINE PASSED!!");
        }
        require(account.currency.transferFrom(msg.sender, address(this), _amount), "FAILED!!");

        if(USA.amountContributed + _amount >= account.target ){
            usersaccount[_member].goalStatus = true;
        }
        usersaccount[_member].ownerAddress = _member;
        usersaccount[_member].amountContributed += _amount;
        account.amountContributed += _amount;

        emit NewSave(_member, _amount, block.timestamp);
    }

    function withdraw(address _member) external validMember(_member) {
        userAccount storage USA = usersaccount[_member];
        uint256 amount = USA.amountContributed;
        if(msg.sender != _member){
           revert Owner("NOT OWNER!!");
        }
        if(amount <= 0){
            revert Amount("NO FUNDS!!!!");
        }
        if(account.endTime > block.timestamp){
            revert Deadline("DEADLINE NOT REACHED");
        }
        if(account.endTime < block.timestamp && !USA.goalStatus){
            uint256 _penaltyfee = amount * 5 / 100;
            uint256 _amount = amount - _penaltyfee;
            USA.amountContributed = 0;
            USA.withdraw = true;
            require(account.currency.transfer(_member, _amount), "FAILED!!");
            require(account.currency.transfer(account.thriftAddress, _penaltyfee), "FAILED!!");
        }else{
            USA.amountContributed = 0;
            USA.withdraw = true;
            require(account.currency.transfer(_member, amount), "FAILED!!");
        }

     
        account.currency.transfer(_member, amount);

        emit NewWithdraw(msg.sender, amount, block.timestamp);
    }

    function getGoal() external {

    }

    function emergencyWithdrawal() external {
        //check if amount saved is not less than the penalty fee
    }

    function getAmountSaved(address _member) view external returns(uint256){
        return usersaccount[_member].amountContributed;

    } 

    function getDeadline() view external returns(uint256){
        return account.endTime;

    }

    function getTarget() view external returns(uint256){
        return account.target;

    }

    function getuserAccount(address _member) view external validMember(_member) returns (userAccount memory){
        return usersaccount[_member];  
    }

    function getAccount() view external returns(Account memory) {
        return account;
    }

    function getAllAcount() view external returns(Account[] memory){
        //uint256[] memory allUserCampaignIndex = allUserCampaings[_userAddress];
        // Account[] memory account = new Account[](totalSingleThrift);
    
        // // for (uint256 i = 0; i < totalSingleThrift; i++) {
        // //     // uint256 campaignIndex = allUserCampaignIndex[i];
        // //     // require(campaignIndex < campaignId, "Invalid campaign index");
        // //     account[i] = Account[i];
        // // }
    
        // return account;

    }

    function _getNextThriftId() internal returns (uint256 id) {
       // if(memberID += 1 > )
        return memberId += 1;
    }

    function amountToSavePerInterval() view public returns(uint256){
        return account.target / (account.duration / account.savingInterval);
    }

    function getCycle() view public returns(uint256 currentCycle){
        uint256 elapsedTime = block.timestamp - account.startTime;
    
        // Calculate the current cycle based on the elapsed time since the start
        currentCycle = elapsedTime / account.savingInterval;
    }

    function paidInCycle(address _member) view public returns(bool){
        return paid[_member][getCycle()];
    }





}