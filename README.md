# Vault Smart Contract

A **secure Ethereum Vault smart contract** built in Solidity, designed for **real-world DeFi applications**. This project demonstrates the use of **Ownable** and **ReentrancyGuard** while allowing users to **deposit ETH with custom lock times**.

---

## Features

- **Custom Lock Times:** Users can deposit ETH and set their own lock period before withdrawal.  
- **Secure Withdrawals:** Protected with `ReentrancyGuard` to prevent reentrancy attacks.  
- **Owner Controls:** The owner can pause deposits if needed.  
- **Balance Tracking:** Each user can check their deposited balance.  
- **Gas Efficient & Safe:** Uses OpenZeppelin best practices and custom errors for better gas optimization.

---

## Real-World Applications

- **Time-Locked Savings / Staking Contracts**  
- **DeFi Vaults and Escrow Systems**  
- **Secure Fund Management Solutions**  

---

## Usage

1. **Clone the repository**  
```bash
git clone https://github.com/amjerd/Vault.git
