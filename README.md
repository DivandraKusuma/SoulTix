# 🎵 SoulTix 2026 — Soulbound Concert Ticket (Anti-Calo)

**BOTChain Build Week Hackathon Submission**
Chain ID Testnet: `968` | Mainnet: `677`

---

## 🎯 Tentang Proyek

dApp tiket konser berbasis NFT **soulbound (non-transferable)** yang dibangun di atas BOT Chain untuk menyelesaikan masalah **calo / ticket scalping** secara on-chain.

### Masalah
Penjualan tiket konser online rawan calo — bot memborong tiket lalu menjual kembali dengan harga tinggi di pasar sekunder. Sistem sentralisasi tidak efektif mencegah hal ini.

### Solusi
Tiket berbentuk NFT **soulbound** yang di-mint langsung ke wallet pembeli. Karena tidak bisa dipindahtangankan secara teknis (enforced di smart contract), tiket tidak bisa dijual di luar sistem resmi.

---

## ✨ Fitur Utama

| Fitur | Detail |
|---|---|
| **Soulbound NFT** | Tiket ERC721 non-transferable — transfer() selalu revert |
| **Limit per Wallet** | Maks. 2 tiket per wallet (`MAX_PER_WALLET = 2`) |
| **Verifikasi Identitas** | Alur Proof of Personhood (simulasi untuk demo) sebelum pembelian |
| **Refund H-2** | Pembeli bisa refund hingga 2 hari sebelum event — tiket di-burn, dana kembali |
| **Anti-Bot** | Limit wallet + verifikasi mencegah bot memborong tiket |
| **Transparan** | Semua transaksi tercatat di BOT Chain, verifiable di BOTScan |

---

## 🔗 Links

- **Contract (Mainnet):** `[CONTRACT_ADDRESS]` → [BOTScan](https://botscan.io)
- **Contract (Testnet):** `[CONTRACT_ADDRESS_TESTNET]` → [BOTScan Testnet](https://testnet.botscan.io)
- **Website Live:** `[DOMAIN]`
- **GitHub:** Repo ini

---

## 📋 Cara Pakai

### Untuk Pembeli

1. **Install MetaMask** dan tambahkan BOT Chain ke network list
2. **Connect Wallet** di website
3. **Verifikasi Identitas** — klik "Verify My Identity", isi form, submit → transaksi on-chain
4. **Beli Tiket** — bayar sejumlah harga tiket dalam BOT token
5. **Lihat Tiket** di section "Tiket Saya" — token ID tercatat on-chain
6. **Refund** (opsional) — tersedia hingga H-2 sebelum event

### Untuk Penyelenggara (Owner)

```bash
# Deploy via Remix IDE
# Constructor parameters:
# - _name: "SoulTix 2026 Ticket"
# - _symbol: "NST26"
# - _eventDate: [unix timestamp event]
# - _ticketPrice: [harga dalam wei, mis. 50000000000000000 = 0.05 BOT]
# - _maxSupply: [total kuota tiket]

# Tarik dana setelah event / setelah refund window tutup:
# contract.withdraw()
```

---

## 🔧 Konfigurasi Network BOT Chain

### Mainnet (Chain ID: 677)
```
Network Name: BOT Chain Mainnet
RPC URL: https://rpc.botchain.network
Chain ID: 677
Currency: BOT
Explorer: https://botscan.io
```

### Testnet (Chain ID: 968)
```
Network Name: BOT Chain Testnet
RPC URL: https://rpc.bohr.life
Chain ID: 968
Currency: BOT
Explorer: https://testnet.botscan.io
```

---

## ⚠️ Limitasi Sybil Resistance (Transparansi)

Proyek ini dirancang dengan prioritas **kejujuran kepada juri** tentang keterbatasan yang ada.

### Limitasi 1: Multi-Wallet Attack
Sistem ini mencegah **satu wallet membeli lebih dari 2 tiket**, namun **tidak mencegah** seseorang membuat banyak wallet berbeda untuk membeli lebih banyak tiket (Sybil attack via multi-wallet).

**Solusi jangka panjang (future work):** Integrasi Proof of Personhood sungguhan seperti:
- [World ID](https://worldcoin.org/world-id) (biometric verification)
- KYC provider pihak ketiga
- DIDs (Decentralized Identifiers)

### Limitasi 2: Verifikasi Identitas Adalah Simulasi (DUMMY)

> **Ini adalah keputusan sadar yang didokumentasikan secara eksplisit.**

Fungsi `verifyMe()` di smart contract saat ini adalah **simulasi Proof of Personhood**, bukan verifikasi sungguhan:

- Siapa saja bisa memanggil `verifyMe()` dan langsung berstatus "verified"
- **Tidak ada** API KYC atau provider pihak ketiga yang dipanggil
- Data nama & nomor identitas yang diisi di form **tidak dikirim ke mana-mana** (hanya UI, bukan parameter contract)
- Catatan ini ditulis sebagai **NatSpec comment** di source code contract, terlihat langsung di BOTScan

**Tujuan simulasi ini:**
Mendemonstrasikan kepada juri *bagaimana alur* Proof of Personhood akan bekerja dalam sistem tiket ini — dari UI verifikasi → transaksi on-chain → status verified yang membuka akses pembelian — tanpa harus membangun integrasi KYC lengkap dalam waktu hackathon.

**Arsitektur versi produksi (future work):**
```
User → Form (nama, nomor ID)
  → Backend/KYC Provider off-chain (proses & simpan data secara aman)
    → Pengecekan identitas sungguhan
      → Hanya hasil (boolean) dikirim ke contract via oracle/wallet backend
        → contract.verifyWallet(userAddress) dipanggil oleh oracle
```
Data identitas mentah **tidak pernah** disimpan on-chain (PII permanen di blockchain = masalah privasi besar).

---

## 📁 Struktur File

```
HackathonWeb3/
├── SoulboundTicket.sol    # Smart contract Solidity (deploy via Remix)
├── index.html             # Frontend dApp single-file (HTML + CSS + JS)
├── README.md              # Dokumentasi ini
└── AGENT.MD               # Spesifikasi build (prompt untuk AI agent)
```

---

## 🛠 Stack Teknologi

- **Smart Contract:** Solidity ^0.8.20, ERC721 minimal (zero-dependency, siap di Remix)
- **Frontend:** HTML + CSS + JavaScript vanilla, ethers.js v6
- **Blockchain:** BOT Chain (EVM-compatible)
- **Wallet:** MetaMask
- **Hosting:** GitHub Pages

---

## 📜 Urutan Deploy

```
1. Buka SoulboundTicket.sol di Remix IDE (remix.ethereum.org)
2. Compile dengan Solidity 0.8.20
3. Deploy ke Testnet (Chain ID 968, RPC: https://rpc.bohr.life)
4. Test semua fungsi: verifyMe → buyTicket → refundTicket
5. Update CONTRACT_ADDRESS di index.html (baris const CONTRACT_ADDRESS = ...)
6. Ubah TARGET_NETWORK ke BOT_CHAIN_MAINNET di index.html
7. Deploy contract yang sama ke Mainnet (Chain ID 677)
8. Update CONTRACT_ADDRESS lagi ke alamat mainnet
9. Push ke GitHub → aktifkan GitHub Pages
10. Arahkan domain ke GitHub Pages
11. Post ke X tag @BOTChain_ai
12. Submit sebelum 23:59!
```

---

## 🏆 Hackathon Deliverables Checklist

- [ ] Contract address di BOT Chain Testnet
- [ ] Contract address di BOT Chain Mainnet
- [ ] Website live di domain sendiri
- [ ] MetaMask terhubung & fungsi end-to-end berjalan
- [ ] Repo GitHub berisi `.sol` + `README.md`
- [ ] README menjelaskan use case, cara pakai, limitasi Sybil resistance
- [ ] README mengungkapkan secara eksplisit bahwa verifikasi identitas adalah simulasi
- [ ] Post di X men-tag @BOTChain_ai

---

*Built with ❤️ untuk BOTChain Build Week Hackathon*
