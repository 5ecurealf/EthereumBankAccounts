pragma solidity >=0.4.22 <=0.8.19;

// Multi-owner Bank Account Contract
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

    // Modifier to check if the caller is the owner of the account
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

    // Modifier to check if the owners of the account are valid. The owners are valid if there are no duplicate owners and
    // the number of owners is less than or equal to 4 (including the account creator). It reverts with an error message if
    // these conditions are not met
    modifier validOwners(address[] calldata owners) {
        require(owners.length + 1 <= 4, "maximum of 4 owners per account");
        for (uint256 i; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                revert("no duplicate owners");
            }
            for (uint256 j = i + 1; j < owners.length; j++) {
                if (owners[i] == owners[j]) {
                    revert("no duplicate owners");
                }
            }
        }
        _;
    }

    // Modifier to check if the account has sufficient balance for a withdrawal.
    // If the amount requested for withdrawal is less than or equal to the account balance, the
    // function execution continues. If not, it reverts with an error message.
    modifier sufficientBalance(uint accountId, uint amount) {
        require(amount <= accounts[accountId].balance, "insufficient funds");
        _;
    }
    // Modifier to check if a withdrawal can be approved. This is validated by checking that the request has not already been
    // approved, that the person approving is not the one making the request, that the request exists, and that the approver
    // has not already approved this request. If these conditions are met, the function execution continues. If not,
    // it reverts with an error message.
    modifier canApprove(uint accountId, uint withdrawId) {
        require(
            !accounts[accountId].withdrawRequests[withdrawId].approved,
            "this request is already approved"
        );
        require(
            accounts[accountId].withdrawRequests[withdrawId].user != msg.sender,
            "you cannot approve this request"
        );
        require(
            accounts[accountId].withdrawRequests[withdrawId].user != address(0),
            "account does not exists"
        );
        require(
            !accounts[accountId].withdrawRequests[withdrawId].ownersApproved[
                msg.sender
            ],
            "you have already approved this request"
        );
        _;
    }

    // Modifier to check if a withdrawal can be made. It checks if the sender is the owner of the withdrawal and that the
    // withdrawal request has been approved by all owners. If these conditions are met, the function execution continues.
    // If not, it reverts with an error message.
    modifier canWithdraw(uint accountId, uint withdrawId) {
        require(
            accounts[accountId].withdrawRequests[withdrawId].user == msg.sender,
            "you cannot withdraw this withdraw request"
        );
        require(
            accounts[accountId].withdrawRequests[withdrawId].approved == true,
            "withdrawal not approved by all owners"
        );
        _;
    }

    // Function to deposit funds into an account. It increases the balance of the specified account by the sent value
    // (msg.value). The function is only callable by an account owner.
    function deposit(uint accountId) external payable accountOwner(accountId) {
        accounts[accountId].balance += msg.value;
    }

    // Function to create a new account with multiple owners. The function caller is added as the last owner of the account.
    // The account ID is generated and incrementally increased every time a new account is created. The function reverts if a
    // user already owns more than 3 accounts. The function emits an 'AccountCreated' event with the owners, account ID,
    // and timestamp. The function is callable by anyone.
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

    // Function to request a withdrawal from an account. A new withdrawal request is created with the sender as the user, and
    // the amount requested for withdrawal. The withdrawal request ID is incrementally increased every time a new request is made.
    // The function emits a 'WithdrawRequested' event with the sender, account ID, withdrawal request ID, amount, and timestamp.
    // The function is only callable by an account owner.
    function requestWithdrawal(
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

    // Function to approve a withdrawal request. It increases the approvals count of the withdrawal request and marks the
    // approver as having approved the request. If the approvals count is equal to the number of owners minus one (excluding the
    // requester), the withdrawal request is marked as approved. The function is only callable by an account owner.
    function approveWithdrawal(
        uint accountId,
        uint withdrawId
    ) external accountOwner(accountId) canApprove(accountId, withdrawId) {
        WithdrawRequest storage request = accounts[accountId].withdrawRequests[
            withdrawId
        ]; //reference to the request for readability
        request.approvals++;
        request.ownersApproved[msg.sender] = true;

        if (request.approvals == accounts[accountId].owners.length - 1) {
            request.approved = true;
        }
    }

    // Function to withdraw funds from an account. It decreases the balance of the account by the amount to withdraw, deletes the
    // withdrawal request to prevent re-entrancy attacks, sends the amount to the sender, and emits a 'Withdraw' event with the
    // withdrawal request ID and timestamp. The function is only callable by an account owner who has a withdrawal request that
    // has been approved by all other owners.
    function withdraw(
        uint accountId,
        uint withdrawId
    ) external canWithdraw(accountId, withdrawId) {
        uint amount = accounts[accountId].withdrawRequests[withdrawId].amount;
        require(accounts[accountId].balance >= amount, "insufficent balance"); // withdrawal may have happened already, so check enough funds in the account again
        accounts[accountId].balance -= amount;

        delete accounts[accountId].withdrawRequests[withdrawId];

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent);

        emit Withdraw(withdrawId, block.timestamp);
    }

    // Getter function to get the balance of an account. Returns the balance of the specified account.
    function getBalance(uint accountId) public view returns (uint) {
        return accounts[accountId].balance;
    }

    // Getter function to get the owners of an account. Returns an array of owner addresses of the specified account.
    function getOwners(uint accountId) public view returns (address[] memory) {
        return accounts[accountId].owners;
    }

    // Getter function to get the approvals of a withdrawal request. Returns the number of approvals a withdrawal request has.
    function getApprovals(
        uint accountId,
        uint withdrawId
    ) public view returns (uint) {
        return accounts[accountId].withdrawRequests[withdrawId].approvals;
    }

    // Getter function to get the accounts of the sender. Returns an array of account IDs that the sender is an owner of.
    function getAccounts() public view returns (uint[] memory) {
        return userAccounts[msg.sender];
    }
}
