# Build Prompt: Anti-Scalper Concert Ticket DApp (Soulbound Ticket)

Use this document as a prompt/spec to build the dApp — paste it directly into Claude Code, ChatGPT, Cursor, or work through it manually step by step. Built for the BOTChain Build Week Hackathon (Testnet Chain ID 968, Mainnet 677).

---

## 1. PROBLEM ANALYSIS & DESIGN

**Problem:** Online concert ticket sales are plagued by scalpers — bots buy up tickets in bulk and resell them at inflated prices on secondary markets.

**Solution:** Tickets are *soulbound* NFTs (non-transferable), minted directly to the buyer's wallet. Because they can't change hands, tickets can't be resold outside the official system.

**Core rules:**
- Each wallet can mint a maximum of 2 tickets (`MAX_PER_WALLET = 2`).
- Tickets cannot be transferred after minting (soulbound) — this prevents resale/scalping.
- Buyers can refund/burn their own ticket **up to 2 days before the event**, after which the slot reopens for someone else to buy.
- The UI shows a wallet verification status (a "Verified Buyer" badge) so judges can see this isn't an ordinary ticket purchase.

**Identity verification (Proof of Personhood) — simulated (dummy) in the UI for demo purposes:**
- Before calling `buyTicket()`, a wallet must have `isVerified = true` in the contract, so the "must verify before buying" flow actually runs on-chain, not just visually.
- Flow: the buyer clicks "Verify My Identity" → fills in a form (name + ID number) → clicks submit → **the frontend directly calls an on-chain function that marks the wallet as verified, with no real data check behind it** (no third-party KYC/Proof of Personhood API is actually called). This is purely to show judges *how* the Proof of Personhood concept would work in the purchase flow, without building a real verification integration that would eat up too much time.
- The name and ID number the user enters **are not stored on-chain or in any backend for this dummy version** — they only populate the UI form and aren't actually processed.
- **Production architecture note (future work):** identity data will still NEVER be stored directly on the blockchain (PII on-chain is permanent and public forever, which is a major privacy problem). The correct future flow: the form sends data to an **off-chain backend/verification provider** (e.g. a third-party KYC provider or an in-house system) that stores and processes the data securely per privacy standards → that provider performs the real identity check → only the **verification result (a true/false boolean)** is pushed to the smart contract via a trusted backend wallet (similar to an oracle pattern), calling a function like `verifyWallet(address)` as originally designed. So raw data stays off-chain; the blockchain only stores the final status — not the data itself.
- **This is explicitly and honestly disclosed in the README**, under "Known Limitations / Future Work": *"Identity verification is currently a simulation (dummy) to demonstrate the Proof of Personhood flow; due to submission time constraints, integration with a real verification provider (e.g. World ID, third-party KYC provider) has not been implemented and is planned future work."* This transparency matters so judges know this was a conscious decision, not an overstated claim.
- One wallet is treated as representing one buyer (which may cover multiple attendees, e.g. a family), not per-individual identity verification of everyone attending.

**Required deliverables per hackathon guidebook:**
1. Contract address on BOT Chain (testnet first, then mainnet).
2. Live website link on your own domain, connected to MetaMask.
3. GitHub repo containing the `.sol` file(s) and a `README.md` (explaining the use case, how to use it, the Sybil-resistance limitations, and an explicit disclosure that identity verification is currently a simulation/dummy).
4. X post tagging @BOTChain_ai.

---

## 2. SMART CONTRACT (Solidity, for Remix IDE)

Build a Solidity contract (pragma ^0.8.20) called `SoulboundTicket.sol` with the following spec:

- Based on the ERC721 standard (either import from OpenZeppelin via Remix, or write a minimal ERC721 manually for zero dependencies).
- **Soulbound:** override the transfer functions (`transferFrom`, `safeTransferFrom` / `_beforeTokenTransfer` depending on the OZ version) so they revert unless it's a mint (`from == address(0)`) or a burn (`to == address(0)`).
- **State variables:**
  - `address public owner` — the event organizer, set in the constructor.
  - `uint256 public eventDate` — event timestamp, set in the constructor.
  - `uint256 public ticketPrice` — price per ticket in BOT (wei).
  - `uint256 public maxSupply` — total ticket quota.
  - `uint256 public totalMinted` — counter of currently active tickets (increments on mint, decrements on burn).
  - `mapping(address => uint256) public ticketsMinted` — active tickets per wallet.
  - `uint256 public constant MAX_PER_WALLET = 2`.
  - `uint256 public constant REFUND_WINDOW = 2 days`.
  - `mapping(address => bool) public isVerified` — verification status per wallet.
- **Verification function (dummy/simulated, NO real data check — documented as a simulation in the README):**
  - `function verifyMe() external` — sets `isVerified[msg.sender] = true` unconditionally, with no requirement beyond having a connected wallet. Emits `event WalletVerified(address indexed wallet, uint256 timestamp);`
  - Deliberately made "callable by anyone for themselves" because this simulates the Proof of Personhood flow rather than performing real verification. This note MUST be written clearly as a NatSpec comment above this function in the source code, so anyone reading the contract (including judges via BOTScan) immediately understands it's a simulation.
- **`buyTicket()` function (payable):**
  - `require(isVerified[msg.sender], "Wallet not verified")`
  - `require(msg.value == ticketPrice, "Wrong payment amount")`
  - `require(ticketsMinted[msg.sender] < MAX_PER_WALLET, "Wallet limit reached")`
  - `require(totalMinted < maxSupply, "Sold out")`
  - Mint a new NFT to `msg.sender`, increment `ticketsMinted[msg.sender]` and `totalMinted`.
  - Emit `event TicketPurchased(address indexed buyer, uint256 indexed tokenId, uint256 timestamp);`
- **`refundTicket(uint256 tokenId)` function:**
  - `require(ownerOf(tokenId) == msg.sender, "Not your ticket")`
  - `require(block.timestamp < eventDate - REFUND_WINDOW, "Refund window closed")`
  - Burn the token, decrement `ticketsMinted[msg.sender]` and `totalMinted`.
  - Refund `ticketPrice` back to `msg.sender` (use `call`, not `transfer`, and check success).
  - Emit `event TicketRefunded(address indexed buyer, uint256 indexed tokenId, uint256 timestamp);`
- **View functions for the frontend:**
  - `function isVerifiedBuyer(address wallet) public view returns (bool)` — returns `ticketsMinted[wallet] > 0`. Used by the UI to show the "Verified Buyer" badge.
  - `function remainingSupply() public view returns (uint256)` — `maxSupply - totalMinted`.
  - `function ticketsOwned(address wallet) public view returns (uint256)` — alias for `ticketsMinted[wallet]`.
- **Admin function (`onlyOwner` modifier):**
  - `withdraw()` — lets the owner withdraw ticket sale proceeds (exclude funds still eligible for refund, or withdraw manually after the refund window closes).
- Add short NatSpec comments (`/// @notice ...`) above every function so judges can easily read it if the contract is verified on BOTScan.

Once the contract is done: compile it in Remix (compiler 0.8.20), deploy to BOT Chain Testnet first (Chain ID 968, RPC `https://rpc.bohr.life`) with `eventDate` set to a timestamp a few days out for testing, then deploy to Mainnet (Chain ID 677) once every function has been validated on testnet.

---

## 2B. TICKET FACTORY (Solidity, connects events together)

**Why it's needed:** so this system can be a reusable *template* that any organizer can use for any event, without redeploying manually or changing code each time. The Factory is a "factory" that spins up new `SoulboundTicket` instances per event, and keeps a registry of every event ever created so the frontend can read it.

**Step 1 — Slightly modify `SoulboundTicket.sol` so it can be deployed from another contract:**
- The constructor takes parameters: `constructor(address _owner, string memory _eventName, uint256 _eventDate, uint256 _ticketPrice, uint256 _maxSupply)`.
- Add `string public eventName` as a state variable, set from the constructor parameter (used by the frontend to display the event name in a dropdown).
- `owner` is set from the `_owner` parameter (not `msg.sender`), because when called from the Factory, `msg.sender` is the Factory's own address, not the real organizer. So: `owner = _owner`.
- Everything else (mint, refund, verify, etc.) stays exactly as specified in section 2.

**Step 2 — Create a new `TicketFactory.sol`:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SoulboundTicket.sol";

/// @title TicketFactory
/// @notice Creates a new SoulboundTicket instance for each event and keeps a registry of them
contract TicketFactory {
    struct EventInfo {
        address contractAddress;
        address organizer;
        string eventName;
        uint256 eventDate;
        uint256 createdAt;
    }

    EventInfo[] public allEvents;

    event EventCreated(
        address indexed eventContract,
        address indexed organizer,
        string eventName,
        uint256 eventDate
    );

    /// @notice Called by an organizer to create a new event and deploy its ticket contract in one go
    function createEvent(
        string memory _eventName,
        uint256 _eventDate,
        uint256 _ticketPrice,
        uint256 _maxSupply
    ) external returns (address) {
        SoulboundTicket newEvent = new SoulboundTicket(
            msg.sender,
            _eventName,
            _eventDate,
            _ticketPrice,
            _maxSupply
        );

        allEvents.push(EventInfo({
            contractAddress: address(newEvent),
            organizer: msg.sender,
            eventName: _eventName,
            eventDate: _eventDate,
            createdAt: block.timestamp
        }));

        emit EventCreated(address(newEvent), msg.sender, _eventName, _eventDate);
        return address(newEvent);
    }

    function getAllEvents() external view returns (EventInfo[] memory) {
        return allEvents;
    }

    function getEventCount() external view returns (uint256) {
        return allEvents.length;
    }

    /// @notice Get only the events created by a specific address (for the "My Events" panel)
    function getEventsByOrganizer(address organizer) external view returns (EventInfo[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < allEvents.length; i++) {
            if (allEvents[i].organizer == organizer) count++;
        }
        EventInfo[] memory result = new EventInfo[](count);
        uint256 j = 0;
        for (uint256 i = 0; i < allEvents.length; i++) {
            if (allEvents[i].organizer == organizer) {
                result[j] = allEvents[i];
                j++;
            }
        }
        return result;
    }
}
```

**Step 3 — How to deploy & connect it in Remix:**
1. Make sure `SoulboundTicket.sol` and `TicketFactory.sol` are in the same folder in Remix (e.g. `contracts/`), and the `import "./SoulboundTicket.sol";` line in the Factory points to the right path.
2. Compile both files together (the compiler automatically compiles imported files too).
3. Only **`TicketFactory`** needs to be deployed — select `TicketFactory` in the contract dropdown before clicking Deploy. `SoulboundTicket` **doesn't need to be deployed manually**, since it will automatically deploy every time `createEvent()` is called.
4. Once the Factory is deployed, test it right from Remix: call `createEvent("Test Concert", <timestamp>, <price>, <quota>)` → check "Deployed Contracts" or the `EventCreated` event log to see the new `SoulboundTicket` address that appears automatically.
5. The Factory address is the **only contract address** you need to save and put in the frontend — not each individual `SoulboundTicket` address, since those are fetched dynamically from `getAllEvents()`.

If you've already deployed an older, single-event version of `SoulboundTicket.sol` (without the Factory) for testing — that's still valid as proof of a "working contract" if you truly run out of time before switching to the Factory. But if there's time left, the Factory version is the stronger thing to demo as a *reusable template*, matching your original intent.

---

## 3. FRONTEND (two modes: Buyer & Event Organizer, ethers.js, connect via MetaMask)

Since there's now a `TicketFactory`, the frontend needs to be aware of **which event** is currently being viewed, and support **two different roles** on the same page. This can be a single HTML file with a "Buy Ticket" / "Organize Event" tab toggle, or two separate pages (`buyer.html` and `organizer.html`) sharing the same contract logic — pick whichever you can finish faster; the functionality is the same either way.

**Constants needed in the script:**
- `FACTORY_ADDRESS` and `FACTORY_ABI` — the address & ABI of `TicketFactory` (the one fixed address you need to hardcode).
- `SOULBOUND_ABI` — the ABI of `SoulboundTicket` (used to dynamically instantiate any event's contract at runtime; the address is fetched from the Factory, not hardcoded).

**Header / Hero:**
- Project name, a **"Connect Wallet"** button, and two tabs: **"🎟 Buy Ticket"** (default) and **"🛠 Organize Event"**.

### Mode A — Buyer (Purchase Ticket)

- After the wallet connects, call `factory.getAllEvents()` → display it as a **list/dropdown of events** (event name + date), taken from the `EventInfo[]` returned by the Factory.
- The user selects an event from the list → the frontend instantiates `new ethers.Contract(selectedEvent.contractAddress, SOULBOUND_ABI, signer)` → every subsequent interaction (verify, buy, refund, view badge) then refers to that selected event's contract, exactly as specified in the earlier version of section 3:
  - Verification badge ("Not Verified" / "✅ Identity Verified") + "Verify My Identity" form (dummy, calls `verifyMe()`).
  - Ticket ownership badge ("🎟 Soulbound Ticket Owned") + "Buy Ticket" button.
  - "My Tickets" section with a "Refund" button (active before H-2).
- If `getAllEvents()` returns empty (no organizer has created an event yet), show a message like "No events available yet" — don't leave a blank page with no explanation.

### Mode B — Event Organizer (Create & Manage Events)

- **"Create New Event"** form: inputs for event name, event date (date picker → converted to a Unix timestamp), ticket price (in BOT), and max ticket quota.
- **"Create Event"** button → calls `factory.createEvent(eventName, eventDate, ticketPriceInWei, maxSupply)` → shows a transaction confirmation + the new contract address that automatically appears from the `EventCreated` event log once the transaction confirms.
- **"My Events"** section: calls `factory.getEventsByOrganizer(connectedWallet)` → displays a list of events created by this wallet, each with a **"Withdraw Funds"** button (calls `withdraw()` on that event's contract, callable only by its `owner`) and quick stats (`totalMinted` / `maxSupply` sold so far).
- This is what you'd demo to judges: "anyone can become their own event organizer through their wallet, without needing to redevelop any code" — that's the core of the "template" idea you had in mind.

**Technical (applies to both modes):**
- Use `ethers.js` v6 from a CDN.
- Detect that the network is BOT Chain (prompt a switch via `wallet_switchEthereumChain` if not).
- Human-readable error handling for every transaction (rejections, reverts, etc.).
- Basic responsiveness (mobile-friendly).

**Deploy:** host on GitHub Pages, point it to the cheap domain ($1–1.5) purchased per the guidebook's instructions.

---

## Recommended execution order (given tomorrow night's deadline)

1. Adjust `SoulboundTicket.sol` (constructor takes parameters, add `eventName`) → write `TicketFactory.sol` → compile both in Remix.
2. Deploy **`TicketFactory`** to BOT Chain Testnet → test directly from Remix: call `createEvent()`, verify the new `SoulboundTicket` appears automatically, test `buyTicket`/`verifyMe`/`refundTicket` on the event contract just created.
3. Build the **Organizer** frontend mode first (create event, view event list) → test creating 1-2 dummy events from the UI.
4. Build the **Buyer** frontend mode (select event from dropdown → verify → buy → view badge → refund) → test end-to-end using the event created in Organizer mode.
5. Once everything runs smoothly on testnet, deploy the same `TicketFactory` to Mainnet (after getting a BOT allocation from the hackathon organizer), update `FACTORY_ADDRESS` in the frontend.
6. Push to GitHub, enable GitHub Pages, point the domain.
7. Write the README.md (use case, how to use both modes, Sybil-resistance limitations, disclosure of dummy verification).
8. Post on X tagging @BOTChain_ai, submit the form before 11:59 PM.

**If time gets really tight:** it's fine to skip the Factory and just use the single-event `SoulboundTicket.sol` version you already deployed for testing — that's still valid proof of a "working contract" for the judging criteria. Mention the Factory as a planned architecture in the README if you don't get to fully implement it.