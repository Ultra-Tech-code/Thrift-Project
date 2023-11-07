// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
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
        uint256 amountContributed;
        bool goalStatus;
    }

    struct userAccount{
        address ownerAddress;
        bool goalStatus;
        uint256 amountContributed;
        bool withdraw;
    }

    error Goal(string);
    error Deadline(string);
    error Owner(string);


    // mapping(address => Account) usersaccount;
    mapping(address => uint256) saved;
    mapping(address => bool) isValid;
    mapping(address => userAccount) usersaccount;

    modifier validMember(address _member){
        require(isValid[_member] == true, "NOT VALID!!");
        _;
    }

    Account account;

    constructor (address _owner,address _thriftAddress, string memory _goalDescription, uint256 _target, uint256 _duration, IERC20 _currency, uint256 _startTime, uint256 _members, address[] memory _membersAddress) {
            for (uint i = 0; i < _members; i++) {
               address member = _membersAddress[i];

                require(member != address(0), "INVALID!!!");
                isValid[member] = true;
            }

            account = Account({
                owner: _owner,
                thriftAddress: _thriftAddress,
                goalDescription: _goalDescription,
                target: _target,
                duration: _duration,
                currency: _currency,
                startTime: _startTime,
                endTime: block.timestamp + _duration,
                members: _members,
                membersAddress: _membersAddress,
                amountContributed: 0,
                goalStatus: false 
            });

            emit NewGoalCreated(_owner, _goalDescription, _target);
    }

    function editGoal(address _owner) external {

       // emit GoalUpdated()

    }

    function save(address _member, uint256 _amount) external validMember(_member) {
        require(_amount > 0, "INVALID!!");
        userAccount storage USA = usersaccount[_member];
        if(USA.goalStatus ){
            revert Goal("TARGET REACHED!!!"); 
        }
        if(account.endTime <= block.timestamp){
            revert Deadline("DEADLINE PASSED!!");
        }
        require(account.currency.transfer(address(this), _amount*1e18), "FAILED!!");
        if(USA.amountContributed + _amount >= account.target ){
            USA.goalStatus = true;
        }
        USA.ownerAddress = _member;
        USA.amountContributed += _amount;
        account.amountContributed += _amount;

        emit NewSave(_member, _amount, block.timestamp);
    }

    function withdraw(address _member) external validMember(_member) {
        userAccount storage USA = usersaccount[_member];
        if(msg.sender != _member){
           revert Owner("NOT OWNER!!");
        }
        require(USA.amountContributed > 0, "NO FUNDS!!");
        if(account.endTime > block.timestamp){
            revert Deadline("DEADLINE NOT REACHED");
        }
        if(!account.goalStatus ){
            //remove penalty fee
        }
        uint256 amount = USA.amountContributed;
        USA.amountContributed = 0;
        USA.withdraw = true;
        account.currency.transferFrom(address(this), _member, amount);

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

    function getAcount() view external returns(Account memory) {
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




}