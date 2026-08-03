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
- **Factory Contract (Mainnet):** `0x4DC63169e3DB8144C242e3C0A10E58B0D8f1ec9A` → [BOTScan Mainnet](https://scan.botchain.ai)
- **Factory Contract (Testnet):** `0xd904FD7d858D7F70e2d9DEBD4567de1299172398` → [BOTScan Testnet]( https://scan.bohr.life/)
- **Website Live:** `www.soultix.my.id`
- **GitHub:** This repository
- **X/Twitter:** https://x.com/rantogudelaaui/status/2084229545746727017?s=46
- **Verified Contract Address:** 0x4DC63169e3DB8144C242e3C0A10E58B0D8f1ec9A
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

### 📱 Mobile Access (Smartphones)
Standard mobile browsers (like Chrome or Safari on iOS/Android) do not support web3 wallet extensions. To use this dApp on a smartphone:
1. Open your Web3 Wallet App (**BO Wallet**, **MetaMask**, **Trust Wallet**, etc.).
2. Navigate to the wallet's built-in **DApp Browser** (usually a compass 🧭 icon).
3. Type in the website URL: `www.soultix.my.id`.
4. The wallet will automatically inject the `window.ethereum` provider, and the "Connect Wallet" button will function exactly like on a desktop.
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

## ⛽ Gas Fee Analytics (BOT Chain)

The following table provides an analytical breakdown of the estimated gas consumption and network fees for each core function on the BOT Chain Mainnet. Because we utilize the Factory pattern and Soulbound NFTs, the fees are heavily optimized for standard operations (like buying and refunding tickets) while the heavy lifting is done once during event creation.

| Smart Contract Function | Action Description | Estimated Gas Used | Network Fee (Avg)* |
| :--- | :--- | :--- | :--- |
| **`TicketFactory (Deploy)`** | Initial setup of the factory (Done once by dev) | `~1,736,250` | `~0.0515 BOT` |
| **`createEvent()`** | Organizer deploys a new `SoulboundTicket` contract | `~1,180,000` | `~0.0347 BOT` |
| **`verifyMe()`** | Buyer verifies identity (Proof of Personhood) | `~45,000` | `~0.0009 BOT` |
| **`buyTicket()`** | Buyer mints a Soulbound NFT to their wallet | `~130,000` | `~0.0021 BOT` |
| **`refundTicket()`** | Ticket is burned, and funds are returned | `~85,000` | `~0.0140 BOT` |
| **`withdraw()`** | Organizer withdraws event earnings | `~38,000` | `< 0.001 BOT` |

*(Note: Network fees in BOT fluctuate based on network congestion. The estimates above are based on historical hackathon testing on BOT Chain Mainnet.)*

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

- [x] Contract address on BOT Chain Testnet
- [x] Contract address on BOT Chain Mainnet
- [x] Website live on custom domain
- [x] MetaMask integration & end-to-end functionality working
- [x] GitHub repo containing `.sol` files + `README.md`
- [x] README explains the use case, how to use it, and Sybil resistance limitations
- [x] README explicitly states that identity verification is a simulation
- [x] Post on X tagging @BOTChain_ai

---

## 🚀 Future Work & Roadmap

While this hackathon project serves as a functional Minimum Viable Product (MVP), we have big plans to evolve SoulTix into a production-ready ticketing platform:

1. **📱 Ticket Scanning App for Organizers**
   - Develop a companion mobile application (or PWA) that allows event organizers to scan the QR codes generated on the frontend.
   - The scanner will instantly verify on-chain ownership using `ownerOf()` and update the status in a backend database to prevent double-entry (e.g., passing a screenshot to a friend).

2. **🔐 Real Proof of Personhood Integration**
   - Replace the current simulated verification with a real decentralized identity protocol (such as Worldcoin/World ID, or a ZK-KYC provider).
   - This ensures a strict 1-person-1-wallet enforcement without compromising user privacy.

3. **💳 Fiat Payment Gateway (Web2.5 Onboarding)**
   - Integrate credit card processing to abstract away crypto complexities for non-crypto natives. Users will be able to buy tickets with fiat, and the backend will automatically purchase BOT tokens and trigger the mint function on their behalf.

4. **🖼 Dynamic NFT Metadata**
   - Implement dynamic metadata (ERC721URIStorage) so the ticket artwork can evolve (e.g., tearing the ticket virtually once it has been scanned at the venue).

---

*Built with ❤️ for the BOTChain Build Week Hackathon*
