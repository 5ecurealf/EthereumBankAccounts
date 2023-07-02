pragma solidity >= 0.4.22 <= 0.8.17;
// multi account owners
// anyone can make deposits
// anyone can request a withdrawal
// all owners of account must approve the request 
contract BankAccount {
    
    event Deposit(
        address indexed user,
        uint indexed accountId,
        uint value,
        uint timestamp
    );
    event WithdrawRequest(address indexed user,
        uint indexed accountId,
        uint indexed withdrawId,
        uint amount,
        uint timestamp
    );

    event Withdraw(uint indexed withdrawId, uint timestamp);

    event AccountCreated(address[] owners, uint indexed id, uint timestamp);

    struct WithdrawRequest {
        address user;
        uint amount;
        uint approvals;
        mapping(address=>bool) ownersApproved;
        bool approved;
    }
    struct Account {
        address[] owners;
        uint balance;
        mapping(uint => WithdrawRequest) withdrawRequests;
    }

    mapping(uint => Account) accounts;
    mapping(address => uint[]) userAccounts;

    // variables to create the id's for the accounts 
    // unique so each time we make a new account we increment the values
    uint nextAccountId;
    uint nextWithdrawId;

    modifier accountOwner(uint accountId){
        bool isOwner;
        for(uint idx; idx < accounts[accountId].owners.length; idx++ ){
            if(accounts[accountId].owners[idx] == msg.sender){
                isOwner = true;
                break;
            }
        }
        require(isOwner,"you are not the owner of this account");
    }

    function deposit(uint accountId) external payable accountOwner(accountId){
        accounts[accountId].balance += msg.value; 
    }
    // caller will specify otherOwners when creating the account 
    function createAccount(address[] calldata otherOwners) external {

    }

    function requestWithdrawl(uint accountId, uint amount) external{

    }

    function approveWtihdrawal(uint accountId, uint withdrawId) external{

    }

    function withdraw(uint accountId, uint withdrawId) external {
        
    }
    
    // getter functions for contract ease of use outside of the contract
    function getBalance(ui accountId) public view returns (uint) {
        
    }

    function getOwners(uint accountId) public view returns (address[] memory) {
        
    }

    function getApprovals(uint accountId,uint withdrawId) public view returns (uint) {
        
    }

    function getAccounts() public view returns (uint[] memory) {
        
    }
}