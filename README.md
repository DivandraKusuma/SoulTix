# 🎵 SoulTix 2026 — The Soulbound Concert Experience

**BOTChain Build Week Hackathon Submission**
Chain ID Testnet: `968` | Mainnet: `677`

---

## 🎯 About The Project

A decentralized ticketing platform based on **soulbound (non-transferable)** NFTs on the BOT Chain network. This project solves two major problems in the entertainment industry:
1. **Eradicating Ticket Scalping:** Tickets are bound to the buyer's wallet (Soulbound), meaning they cannot be transferred or resold on secondary markets.
2. **Open Event Creation:** Utilizing a *Factory Pattern* architecture, anyone can become an *Organizer* and deploy their own event smart contract directly from the website without writing any code.

---

## ✨ Key Features

| Feature | Detail |
|---|---|
| **Soulbound NFT** | Non-transferable ERC721 tickets — the `transfer()` function will always revert. |
| **Ticket Factory** | *Organizers* can create their own events and ticket contracts via the UI. |
| **Wallet Limit** | Max 2 tickets per wallet per event (`MAX_PER_WALLET = 2`). |
| **Identity Verification** | *Proof of Personhood* workflow (simulation) required before purchase. |
| **Refunds (up to D-2)** | Buyers can refund their tickets up to 2 days before the event — the ticket is burned and funds are returned. |
| **Anti-Bot Mechanism** | Wallet limits + identity verification prevent bots from sweeping tickets. |
| **Modern Flat UI** | A clean, responsive, modern user interface featuring a Tab navigation system. |

---

## 🔗 Links
- **Factory Contract (Mainnet):** `` → [BOTScan Mainnet](https://scan.botchain.ai)
- **Factory Contract (Testnet):** `0xd904FD7d858D7F70e2d9DEBD4567de1299172398` → [BOTScan Testnet]( https://scan.bohr.life/)
- **Website Live:** `www.soultix.my.id`
- **GitHub:** This repository

---

## 📋 How to Use

### 🎟 For Buyers (Buy Ticket)
1. **Connect Wallet** (MetaMask) and make sure you are connected to the BOT Chain network.
2. Select an available event from the **Available Events** list.
3. **Verify Identity** — click "Verify My Identity" to simulate an on-chain *Proof of Personhood*.
4. **Buy Ticket** — purchase the ticket using BOT tokens.
5. **View Ticket** in the "My Tickets" section — your Token ID is permanently recorded on-chain.
6. **Refund** (optional) — can be done as long as the refund window is open (up to 2 days before the event).

### 🛠 For Organizers (Organize Event)
1. Navigate to the **Organize Event** tab.
2. Enter the event name, date, ticket price, and total ticket supply.
3. Click **Create Event**. This transaction calls the `TicketFactory` to dynamically deploy a new `SoulboundTicket` smart contract exclusively for your event.
4. Once the event is over or the refund window closes, you can withdraw the ticket sales revenue by clicking the **Withdraw Funds** button.

---

## 🔧 BOT Chain Network Configuration

### Mainnet (Chain ID: 677)
```
Network Name: BOT Chain Mainnet
RPC URL: https://rpc.botchain.network
Chain ID: 677
Currency: BOT
Explorer: https://scan.botchain.ai/
```

### Testnet (Chain ID: 968)
```
Network Name: BOT Chain Testnet
RPC URL: https://rpc.bohr.life
Chain ID: 968
Currency: BOT
Explorer: https://scan.bohr.life/
```

---

## ⚠️ Sybil Resistance Limitations (Transparency)

This project was built with a priority of **honesty and transparency towards the judges** regarding its limitations.

### Limitation 1: Multi-Wallet Attack
The system prevents a single wallet from buying more than 2 tickets, but it **does not prevent** an individual from creating multiple wallets to buy more tickets (Sybil attack).
**Future Solution:** Real KYC integration, biometrics (e.g., World ID), or Decentralized Identifiers (DIDs).

### Limitation 2: Identity Verification is a Simulation (DUMMY)
The `verifyMe()` function in the smart contract is currently a **Proof of Personhood simulation**, not a real verification:
- Anyone can call `verifyMe()` and their status becomes "verified".
- **Any ID inputted in the form (whether it's a National ID card, Student ID, or others) is NEVER sent to the blockchain.** In a real production environment, this sensitive data would only be sent to a secure off-chain verifier's database (KYC Provider), and only the final *verified status* would be pushed to the blockchain.

The purpose of this simulation is to demonstrate the **UX / workflow** of *Proof of Personhood* (verification → transaction → unlocking the purchase button) within the hackathon time constraints.

---

## 📁 File Structure

```
SoulTic/
├── TicketFactory.sol      # Main factory contract (On-chain registry for all events)
├── SoulboundTicket.sol    # Blueprint/Template contract for individual event tickets
├── index.html             # dApp Frontend (Flat Design UI, integrated with ethers.js)
├── README.md              # This documentation
├── Catatan.md             # Development notes/history
└── AGENT.MD               # Initial AI agent prompt/specifications
```

---

## 🛠 Technology Stack

- **Smart Contract:** Solidity ^0.8.20, Factory Pattern
- **Frontend:** HTML + CSS (Flat Modern) + Vanilla JavaScript, ethers.js v6
- **Blockchain:** BOT Chain (EVM-compatible)
- **Wallet:** MetaMask
- **Hosting:** GitHub Pages

---

## 📜 Redeployment Steps (If Needed)

If you wish to redeploy the system from scratch, follow these steps:
1. Open Remix IDE (remix.ethereum.org).
2. Create `SoulboundTicket.sol` and `TicketFactory.sol` and paste the latest code.
3. Compile **TicketFactory.sol** (ensure compiler version is 0.8.20).
4. **IMPORTANT:** Deploy *only* the `TicketFactory` to BOT Chain Testnet/Mainnet. The `SoulboundTicket` contract does not need to be deployed manually as the Factory will deploy it automatically.
5. Copy the newly deployed `TicketFactory` contract address.
6. Open `index.html` and update the configuration line: `const FACTORY_ADDRESS = "YOUR_NEW_ADDRESS";`.
7. Refresh the website, and anyone can start creating events!

---

## 🏆 Hackathon Deliverables Checklist

- [ ] Contract address on BOT Chain Testnet
- [ ] Contract address on BOT Chain Mainnet
- [ ] Website live on custom domain
- [ ] MetaMask integration & end-to-end functionality working
- [ ] GitHub repo containing `.sol` files + `README.md`
- [ ] README explains the use case, how to use it, and Sybil resistance limitations
- [ ] README explicitly states that identity verification is a simulation
- [ ] Post on X tagging @BOTChain_ai

---

*Built with ❤️ for the BOTChain Build Week Hackathon*
