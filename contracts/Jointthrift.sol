// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./IERC20.sol";


contract Jointthrift {
    uint256 memberId;

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
        uint256 amountRaised;
        bool withdraw;
    }

    event NewGoalCreated(address indexed owner, string indexed goalDescription, uint256 indexed target);
    event GoalUpdated(address indexed owner, uint256 indexed Thriftid, uint256 updateTime);

    error NotGoal();
    error NotDeadline();

    modifier validMember(address _member){
        require(isValid[_member] == true, "NOT VALID!!");
        _;
    }


    // mapping(address => Account) accounts;
    mapping(address => uint256) saved;
    mapping(address => bool) isValid;
    mapping(address => userAccount) usersaccount;

    constructor (address _owner,address _thriftAddress, string memory _goalDescription, uint256 _target, uint256 _duration, IERC20 _currency, uint256 _startTime, uint256 _members, address[] memory _membersAddress) {

            Account account = Account({
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

            for (uint i = 0; i < _members; i++) {
               address member = _membersAddress[i];

                require(member != address(0), "INVALID!!!");
                isValid[member] = true;
            }

            emit NewGoalCreated(_owner, _goalDescription, _target);
    }

    function editGoal(address _owner, uint256 _thriftid) external {

       // emit GoalUpdated()

    }

    function save(address _member, uint256 _amount) external validMember(_member) {
        require(_amount > 0, "INVALID!!");
        userAccount memory act = usersaccount[_member];
        act.ownerAddress = _member;
        act.amountRaised += _amount;

        Account memory account;
        require(account.currency.transfer(address(this), _amount*1e18), "FAILED!!");
        
        
        require(!account.goalStatus, "TARGET REACHED");

        if(account.amountContributed + _amount >= account.target ){
            accounts[_owner][_thriftid].goalStatus = true;
        }
        accounts[_owner][_thriftid].amountContributed += _amount;
    }

    function withdraw(address _owner, uint256 _thriftid) external {
        Account memory account = accounts[_owner][_thriftid];
        require(account.amountContributed > 0, "NO FUNDS!!");
        if(!account.goalStatus ){
            revert NotGoal(); 
        }
        if(account.endTime > block.timestamp){
            revert NotDeadline();
        }

        accounts[_owner][_thriftid].amountContributed = 0;
    }

    function getGoal() external {

    }

    function emergencyWithdrawal() external {
        //check if amount saved is not less than the penalty fee
    }

    function getAmountSaved(address _owner, uint256 _thriftid) view external returns(uint256){
        return accounts[_owner][_thriftid].amountContributed;

    } 

    function getDeadline(address _owner, uint256 _thriftid) view external returns(uint256){
        return accounts[_owner][_thriftid].endTime;

    }

    function getTarget(address _owner, uint256 _thriftid) view external returns(uint256){
        return accounts[_owner][_thriftid].target;

    }

    function getuserAccount(address _owner, uint256 _thriftid) view external returns(Account memory){
        return accounts[_owner][_thriftid];
        
    }

    function getusersAllAcount() view external {

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