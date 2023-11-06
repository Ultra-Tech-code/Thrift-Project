// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./IERC20.sol";


contract SingleThrift {

    struct Account {
        address owner;
        uint256 thriftID;
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


    mapping(address => mapping(uint256 => Account)) accounts;
    mapping(address => uint256[]) contributionCreated;

    function createGoal(address _owner, string memory _goalDescription, uint256 _target, uint256 _duration, IERC20 _currency, uint256 _startTime ) external returns(uint256 thriftID) {


            Account memory account = Account({
                owner: _owner,
                thriftID: thriftID,
                goalDescription: _goalDescription,
                target: _target,
                duration: _duration,
                currency: _currency,
                startTime: _startTime,
                endTime: block.timestamp + _duration,
                amountContributed: 0,
                goalStatus: false 
            });

            accounts[_owner][thriftID] = account;

            emit NewGoalCreated(_owner,_goalDescription, thriftID);

    }

    function editGoal(address _owner, uint256 _thriftid) external {

       // emit GoalUpdated()

    }

    function save(address _owner, uint256 _thriftid, uint256 _amount) external {
        Account memory account = accounts[_owner][_thriftid];
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
        Account[] memory account = new Account[](totalSingleThrift);
    
        // for (uint256 i = 0; i < totalSingleThrift; i++) {
        //     // uint256 campaignIndex = allUserCampaignIndex[i];
        //     // require(campaignIndex < campaignId, "Invalid campaign index");
        //     account[i] = Account[i];
        // }
    
        return account;

    }




}