Multi-Owner Solidity Bank Account
This repository contains a smart contract written in Solidity for a multi-owner bank account system, supporting a decentralized banking model in Ethereum Blockchain. The contract is designed to regulate transactions within an account owned by multiple individuals. It offers the following functionalities:

Multiple Account Owners: An account can be created with up to 4 unique owners including the creator of the account. Each user can own a maximum of 3 accounts.

Deposits: Any owner can deposit Ether into the account. The balance of the account is updated accordingly.

Withdrawal Requests: Any owner can request a withdrawal from the account. The request must specify the amount to be withdrawn, which can't exceed the current balance of the account. The request is identified by a unique withdrawal ID.

Approvals for Withdrawal Requests: For a withdrawal to be processed, all account owners (excluding the requester) must approve the withdrawal request. An owner can approve a request only once.

Withdrawals: Upon receiving all required approvals, the requester can initiate the withdrawal. The amount is transferred from the account to the requester's address, and the account balance is updated.

Contract Events: The contract emits events to track the execution of significant operations such as deposit, withdrawal request, approval of withdrawal, and account creation.

Getter Functions: Several public view functions are available for retrieving details such as account balance, account owners, approval counts for a withdrawal request, and a list of account IDs owned by a user.

Please note that this contract does not include any functionality to create and manage users. It assumes that the Ethereum addresses are valid and belong to the users involved in transactions.

Feel free to clone, fork, or contribute to this project. If you find any bugs or improvements, please raise an issue or submit a pull request.
