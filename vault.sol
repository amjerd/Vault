// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Custom errors for more gas efficient error handling
error InsufficientBalance(uint256 userBalance, uint256 requestedAmount);
error MustBeGreaterThanZero();
error InvalidLockTime();
error WithdrawalLocked(uint256 unlockTime);
error FailedToSend();
error DepositPausedCheckBackLater();

contract Vault is Ownable(msg.sender), ReentrancyGuard {

    // Boolean to allow the owner to pause deposits
    bool public depositPaused;

    // Events to log deposits, withdrawals, and deposit pause state
    event Deposited(address indexed user, uint256 amount, uint256 lockTime);
    event Withdrawn(address indexed user, uint256 amount);
    event DepositPaused(bool paused);

    // Mapping to track user balances and Mapping to track when a user can withdraw their funds
    mapping(address => uint256) public balances;
    mapping(address => uint256) public unlockAt;

    // Deposit function allows users to send ETH to the contract
    // Users specify a lock time in seconds
    function deposit(uint256 lockTimeInSeconds) external payable {
        // Revert if deposits are currently paused,if the deposit amount is zero and if the lock time is zero
        if(depositPaused) revert DepositPausedCheckBackLater();
        if (msg.value == 0) revert MustBeGreaterThanZero();
        if (lockTimeInSeconds == 0) revert InvalidLockTime();

        // Increase the sender's balance
        balances[msg.sender] += msg.value;

        // Set the unlock timestamp for this user
        unlockAt[msg.sender] = block.timestamp + lockTimeInSeconds;

        // Emit event with deposit details
        emit Deposited(msg.sender, msg.value, lockTimeInSeconds);
    }

    // Withdraw function allows users to retrieve their ETH
    // Only allows withdrawal after the lock period
    function withdraw(uint256 amount) external nonReentrant {
       uint256 Balance = balances[msg.sender];

       // Revert if user tries to withdraw more than their balance
       if(Balance < amount){
        revert InsufficientBalance(Balance,amount);
       }

        // Revert if the user's funds are still locked
        if (block.timestamp < unlockAt[msg.sender]) {
            revert WithdrawalLocked(unlockAt[msg.sender]);
        }

        // Deduct the withdrawn amount from the user's balance
        balances[msg.sender] -= amount;

        // Send ETH to the user safely and revert if it fails
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert FailedToSend();

        // Emit event to log withdrawal
        emit Withdrawn(msg.sender, amount);
    }

    // Function for users to check their current balance
    function checkBalance() external view returns (uint256){
        return balances[msg.sender];
    }

    // Function for the owner to check total ETH in the contract
    function totalContractBalance() external view onlyOwner returns (uint256){
        return address(this).balance;
    }

    // Owner-only function to pause or resume deposits
    function setDepositPaused(bool _paused) external onlyOwner{
        depositPaused = _paused;
        // Emit event to notify off-chain listeners
        emit DepositPaused(_paused);
    }

}
