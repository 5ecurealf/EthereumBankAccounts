pragma solidity >=0.4.22 <=0.8.19;

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
    event WithdrawRequested(
        address indexed user,
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
        mapping(address => bool) ownersApproved;
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

    modifier accountOwner(uint accountId) {
        bool isOwner;
        for (uint idx; idx < accounts[accountId].owners.length; idx++) {
            if (accounts[accountId].owners[idx] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "you are not the owner of this account");
        _;
    }

    modifier validOwners(address[] calldata owners) {
        require(owners.length + 1 <= 4, "maximum of 4 owners per account");
        for (uint256 i; i < owners.length; i++) {
            for (uint256 j = i + 1; j < owners.length; j++) {
                if (owners[i] == owners[j]) {
                    revert("no duplicate owners");
                }
            }
        }
        _;
    }

    modifier sufficientBalance(uint accountId, uint amount) {
        require(amount <= accounts[accountId].balance, "insufficient funds");
        _;
    }

    function deposit(uint accountId) external payable accountOwner(accountId) {
        accounts[accountId].balance += msg.value;
    }

    // caller will specify otherOwners when creating the account
    // limit of 4 owners of the account
    // each owner passed is unique
    // max 3 other accounts, make sure each owner doesn't own too many accounts

    function createAccount(
        address[] calldata otherOwners
    ) external validOwners(otherOwners) {
        address[] memory owners = new address[](otherOwners.length + 1); // +1 so I can add the caller of the function to the array
        owners[otherOwners.length] = msg.sender; //make the caller the last person in the array

        uint id = nextAccountId;

        // check if the otherOwners have less than 3 accounts
        for (uint idx; idx < owners.length; idx++) {
            if (idx < owners.length - 1) {
                owners[idx] = otherOwners[idx];
            }

            if (userAccounts[owners[idx]].length > 2) {
                revert("each user can have a max of 3 accounts");
            }
            userAccounts[owners[idx]].push(id);

            accounts[id].owners = owners;
            nextAccountId++;
            emit AccountCreated(owners, id, block.timestamp);
        }
    }

    // user cannot request more funds than what is in the account
    // msg.sender has to be an owner of the account
    function requestWithdrawl(
        uint accountId,
        uint amount
    ) external accountOwner(accountId) sufficientBalance(accountId, amount) {
        uint id = nextWithdrawId;
        WithdrawRequest storage request = accounts[accountId].withdrawRequests[
            id
        ];
        request.user = msg.sender;
        request.amount = amount;
        nextWithdrawId++;
        emit WithdrawRequested(
            msg.sender,
            accountId,
            id,
            amount,
            block.timestamp
        );
    }

    function approveWtihdrawal(uint accountId, uint withdrawId) external {}

    function withdraw(uint accountId, uint withdrawId) external {}

    // getter functions for contract ease of use outside of the contract
    function getBalance(uint accountId) public view returns (uint) {}

    function getOwners(uint accountId) public view returns (address[] memory) {}

    function getApprovals(
        uint accountId,
        uint withdrawId
    ) public view returns (uint) {}

    function getAccounts() public view returns (uint[] memory) {}
}
