// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SoulboundTicket
 * @author BOTChain Hackathon Team
 * @version 1.0.1
 * @notice Soulbound (non-transferable) ERC721 concert ticket to prevent ticket scalping.
 *         Tickets are minted directly to the buyer's wallet and cannot be transferred.
 *         Built for the BOTChain Build Week Hackathon (Testnet Chain ID: 968, Mainnet: 677).
 *
 * @dev This contract can be deployed standalone OR via TicketFactory.
 *      When deployed via TicketFactory, the _owner parameter must be the organizer's
 *      wallet address so that ownership does NOT end up on the Factory contract address.
 */
contract SoulboundTicket {
    // -------------------------------------------------------------------------
    //  Minimal ERC721 (zero external dependency, fully self-contained)
    // -------------------------------------------------------------------------

    string public name;
    string public symbol;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // -------------------------------------------------------------------------
    //  Events
    // -------------------------------------------------------------------------

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner_, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner_, address indexed operator, bool approved);

    /// @notice Emitted when a wallet successfully calls verifyMe().
    event WalletVerified(address indexed wallet, uint256 timestamp);

    /// @notice Emitted when a ticket is purchased.
    event TicketPurchased(address indexed buyer, uint256 indexed tokenId, uint256 timestamp);

    /// @notice Emitted when a ticket is refunded and burned.
    event TicketRefunded(address indexed buyer, uint256 indexed tokenId, uint256 timestamp);

    // -------------------------------------------------------------------------
    //  State Variables
    // -------------------------------------------------------------------------

    /// @notice Event organizer wallet. Set in constructor, cannot change except via transferOwnership.
    address public owner;

    /// @notice Human-readable event name (e.g. "SoulTix 2026"). Used by the TicketFactory registry.
    string public eventName;

    /// @notice Unix timestamp of the event date.
    uint256 public eventDate;

    /// @notice Ticket price in wei (native BOT token).
    uint256 public ticketPrice;

    /// @notice Maximum number of tickets that can be minted.
    uint256 public maxSupply;

    /// @notice Number of currently active tickets (increases on mint, decreases on refund/burn).
    uint256 public totalMinted;

    /// @notice Internal counter for the next token ID (starts at 1).
    uint256 private _nextTokenId;

    /// @notice Number of active (non-refunded) tickets held by each wallet.
    mapping(address => uint256) public ticketsMinted;

    /// @notice Identity verification status per wallet (dummy/simulated for hackathon demo).
    mapping(address => bool) public isVerified;

    /// @notice Stores token IDs owned by each wallet for efficient frontend reads.
    mapping(address => uint256[]) private _walletTokens;

    /// @notice Maximum tickets per wallet.
    uint256 public constant MAX_PER_WALLET = 2;

    /// @notice Refund is only allowed more than 2 days before the event.
    uint256 public constant REFUND_WINDOW = 2 days;

    // -------------------------------------------------------------------------
    //  Modifiers
    // -------------------------------------------------------------------------

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the event organizer");
        _;
    }

    // -------------------------------------------------------------------------
    //  Constructor
    // -------------------------------------------------------------------------

    /**
     * @notice Deploy a soulbound concert ticket contract.
     * @param _owner Address of the event organizer. When deployed via TicketFactory,
     *               pass the organizer's wallet so the Factory address is NOT the owner.
     * @param _eventName Human-readable event name stored on-chain (used by Factory registry).
     * @param _name ERC721 token name (e.g. "SoulTix 2026 Ticket").
     * @param _symbol ERC721 token symbol (e.g. "NST26").
     * @param _eventDate Unix timestamp of the event. Must be in the future.
     * @param _ticketPrice Ticket price in wei.
     * @param _maxSupply Total ticket quota. Must be > 0.
     */
    constructor(
        address _owner,
        string memory _eventName,
        string memory _name,
        string memory _symbol,
        uint256 _eventDate,
        uint256 _ticketPrice,
        uint256 _maxSupply
    ) {
        require(_owner != address(0), "Owner cannot be zero address");
        require(_eventDate > block.timestamp, "Event date must be in the future");
        require(_maxSupply > 0, "Max supply must be > 0");
        owner       = _owner;
        eventName   = _eventName;
        name        = _name;
        symbol      = _symbol;
        eventDate   = _eventDate;
        ticketPrice = _ticketPrice;
        maxSupply   = _maxSupply;
        _nextTokenId = 1;
    }


    // ─────────────────────────────────────────────────────────────
    //  ERC721 Core (Soulbound Override)
    // ─────────────────────────────────────────────────────────────

    /**
     * @dev Soulbound enforcement: transfer hanya diizinkan saat mint (from == address(0))
     *      atau burn (to == address(0)). Semua transfer lain di-revert.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /*tokenId*/
    ) internal pure {
        // Mint: from == address(0) — diizinkan
        // Burn: to == address(0) — diizinkan
        // Transfer normal: REVERT — soulbound enforcement
        require(
            from == address(0) || to == address(0),
            "SoulboundTicket: token is non-transferable (soulbound)"
        );
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        _beforeTokenTransfer(from, to, tokenId);
        // Logika transfer standar (hanya akan dieksekusi jika lolos _beforeTokenTransfer)
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        // Simplified: tidak ada callback receiver check karena soulbound
        (data); // silence unused warning
    }

    // ─────────────────────────────────────────────────────────────
    //  ERC721 Standard Functions
    // ─────────────────────────────────────────────────────────────

    function balanceOf(address wallet) public view returns (uint256) {
        require(wallet != address(0), "Zero address");
        return _balances[wallet];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    function approve(address /*to*/, uint256 /*tokenId*/) public pure {
        revert("SoulboundTicket: approvals disabled (soulbound)");
    }

    function setApprovalForAll(address /*operator*/, bool /*approved*/) public pure {
        revert("SoulboundTicket: approvals disabled (soulbound)");
    }

    function getApproved(uint256 /*tokenId*/) public pure returns (address) {
        return address(0);
    }

    function isApprovedForAll(address /*owner_*/, address /*operator*/) public pure returns (bool) {
        return false;
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x80ac58cd || // ERC721
            interfaceId == 0x01ffc9a7;   // ERC165
    }

    // ─────────────────────────────────────────────────────────────
    //  Internal Helpers
    // ─────────────────────────────────────────────────────────────

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address tokenOwner = ownerOf(tokenId);
        return spender == tokenOwner;
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "Mint to zero address");
        require(_owners[tokenId] == address(0), "Token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address tokenOwner = ownerOf(tokenId);
        _beforeTokenTransfer(tokenOwner, address(0), tokenId);
        delete _tokenApprovals[tokenId];
        _balances[tokenOwner] -= 1;
        delete _owners[tokenId];
        emit Transfer(tokenOwner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "Not token owner");
        require(to != address(0), "Transfer to zero address");
        delete _tokenApprovals[tokenId];
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    // ─────────────────────────────────────────────────────────────
    //  Verification (Dummy / Simulasi — BUKAN verifikasi sungguhan)
    // ─────────────────────────────────────────────────────────────

    /**
     * @notice [SIMULASI PROOF OF PERSONHOOD — BUKAN VERIFIKASI SUNGGUHAN]
     *
     *         Fungsi ini SENGAJA dibuat tanpa pengecekan data apapun sebagai SIMULASI
     *         alur Proof of Personhood untuk keperluan demo hackathon.
     *
     *         Siapa saja bisa memanggil fungsi ini untuk diri sendiri dan langsung
     *         berstatus "verified" — tidak ada API KYC atau provider pihak ketiga
     *         yang benar-benar dipanggil di balik layar.
     *
     *         UNTUK VERSI PRODUKSI (future work): hanya backend/oracle tepercaya
     *         yang seharusnya memanggil fungsi `verifyWallet(address)` setelah
     *         memverifikasi identitas user via provider off-chain (mis. World ID,
     *         KYC provider pihak ketiga). Data identitas mentah TIDAK PERNAH
     *         disimpan on-chain demi alasan privasi (PII permanen di blockchain).
     *
     * @dev Emit WalletVerified sehingga frontend bisa mendeteksi perubahan status.
     */
    function verifyMe() external {
        require(!isVerified[msg.sender], "Wallet already verified");
        isVerified[msg.sender] = true;
        emit WalletVerified(msg.sender, block.timestamp);
    }

    // ─────────────────────────────────────────────────────────────
    //  Core Business Logic
    // ─────────────────────────────────────────────────────────────

    /**
     * @notice Beli tiket konser. Wallet harus sudah terverifikasi via verifyMe().
     * @dev Mengirimkan sejumlah persis ticketPrice dalam native token (BOT).
     *      Tiket berbentuk NFT soulbound — tidak bisa ditransfer setelah mint.
     */
    function buyTicket() external payable {
        require(isVerified[msg.sender], "Wallet not verified - call verifyMe() first");
        require(msg.value == ticketPrice, "Wrong payment amount");
        require(ticketsMinted[msg.sender] < MAX_PER_WALLET, "Wallet limit reached (max 2 tickets)");
        require(totalMinted < maxSupply, "Sold out");
        require(block.timestamp < eventDate, "Event has already passed");

        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        totalMinted++;
        ticketsMinted[msg.sender]++;
        _walletTokens[msg.sender].push(tokenId);

        _mint(msg.sender, tokenId);

        emit TicketPurchased(msg.sender, tokenId, block.timestamp);
    }

    /**
     * @notice Refund tiket — burn NFT dan kembalikan dana ke pembeli.
     *         Hanya bisa dilakukan sebelum H-2 event (refund window).
     * @param tokenId ID token yang akan di-refund.
     */
    function refundTicket(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not your ticket");
        require(
            block.timestamp < eventDate - REFUND_WINDOW,
            "Refund window closed (must be > 2 days before event)"
        );

        ticketsMinted[msg.sender]--;
        totalMinted--;

        // Hapus token dari array wallet
        uint256[] storage tokens = _walletTokens[msg.sender];
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }

        _burn(tokenId);

        // Refund menggunakan call (lebih aman dari transfer/send)
        (bool success, ) = payable(msg.sender).call{value: ticketPrice}("");
        require(success, "Refund transfer failed");

        emit TicketRefunded(msg.sender, tokenId, block.timestamp);
    }

    // ─────────────────────────────────────────────────────────────
    //  View Functions (untuk frontend)
    // ─────────────────────────────────────────────────────────────

    /**
     * @notice Cek apakah wallet sudah pernah membeli tiket.
     *         Digunakan frontend untuk menampilkan badge "Verified Buyer".
     * @param wallet Alamat wallet yang dicek.
     * @return true jika wallet saat ini memiliki minimal 1 tiket aktif.
     */
    function isVerifiedBuyer(address wallet) public view returns (bool) {
        return ticketsMinted[wallet] > 0;
    }

    /**
     * @notice Sisa kuota tiket yang masih tersedia.
     * @return Jumlah tiket yang belum terjual.
     */
    function remainingSupply() public view returns (uint256) {
        return maxSupply - totalMinted;
    }

    /**
     * @notice Jumlah tiket aktif (belum di-refund) yang dimiliki wallet.
     * @param wallet Alamat wallet yang dicek.
     * @return Jumlah tiket aktif.
     */
    function ticketsOwned(address wallet) public view returns (uint256) {
        return ticketsMinted[wallet];
    }

    /**
     * @notice Mendapatkan semua token ID yang dimiliki wallet.
     *         Berguna untuk frontend menampilkan list tiket di section "My Tickets".
     * @param wallet Alamat wallet yang dicek.
     * @return Array token ID yang dimiliki (hanya yang masih aktif/belum di-burn).
     */
    function getWalletTokens(address wallet) public view returns (uint256[] memory) {
        uint256[] storage allTokens = _walletTokens[wallet];
        uint256 activeCount = 0;
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (_owners[allTokens[i]] != address(0)) {
                activeCount++;
            }
        }
        uint256[] memory activeTokens = new uint256[](activeCount);
        uint256 idx = 0;
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (_owners[allTokens[i]] != address(0)) {
                activeTokens[idx] = allTokens[i];
                idx++;
            }
        }
        return activeTokens;
    }

    /**
     * @notice Cek apakah refund masih tersedia untuk saat ini.
     * @return true jika masih dalam refund window (lebih dari 2 hari sebelum event).
     */
    function isRefundAvailable() public view returns (bool) {
        return block.timestamp < eventDate - REFUND_WINDOW;
    }

    /**
     * @notice Timestamp batas akhir refund (eventDate - 2 days).
     * @return Unix timestamp batas refund.
     */
    function refundDeadline() public view returns (uint256) {
        return eventDate - REFUND_WINDOW;
    }

    // ─────────────────────────────────────────────────────────────
    //  Admin Functions
    // ─────────────────────────────────────────────────────────────

    /**
     * @notice Tarik dana hasil penjualan tiket ke wallet penyelenggara.
     *         Disarankan dipanggil setelah refund window tutup untuk menghindari
     *         ketidakcukupan dana refund. Seluruh saldo contract ditarik.
     * @dev Hanya bisa dipanggil oleh owner/penyelenggara event.
     */
    function withdraw() external onlyOwner {
        require(!isRefundAvailable(), "Cannot withdraw before refund window closes");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdraw failed");
    }

    /**
     * @notice Lihat saldo dana di contract (hasil penjualan tiket).
     * @return Saldo dalam wei.
     */
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Transfer ownership ke alamat baru.
     * @param newOwner Alamat owner baru.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        owner = newOwner;
    }

    /**
     * @notice Update harga tiket (hanya sebelum ada yang membeli).
     * @param newPrice Harga baru dalam wei.
     */
    function updateTicketPrice(uint256 newPrice) external onlyOwner {
        require(totalMinted == 0, "Cannot change price after tickets sold");
        ticketPrice = newPrice;
    }
}
