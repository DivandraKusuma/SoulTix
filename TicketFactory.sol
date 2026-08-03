// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SoulboundTicket.sol";

/**
 * @title TicketFactory
 * @author BOTChain Hackathon Team
 * @version 1.0.1
 * @notice Factory contract that creates a new SoulboundTicket instance for each event
 *         and maintains an on-chain registry of all events ever created.
 *
 * @dev Deployment flow:
 *   1. Deploy ONLY this TicketFactory contract in Remix.
 *   2. SoulboundTicket.sol does NOT need to be deployed manually � it deploys automatically
 *      each time an organizer calls createEvent().
 *   3. Save the TicketFactory address in the frontend config (FACTORY_ADDRESS).
 *   4. The frontend fetches all event contracts dynamically via getAllEvents().
 *
 * BOTChain Build Week Hackathon (Testnet Chain ID: 968, Mainnet: 677).
 */
contract TicketFactory {

    // -------------------------------------------------------------------------
    //  Data Structures
    // -------------------------------------------------------------------------

    struct EventInfo {
        address contractAddress; // Address of the deployed SoulboundTicket contract
        address organizer;       // Wallet that called createEvent()
        string  eventName;       // Human-readable event name
        uint256 eventDate;       // Unix timestamp of the event
        uint256 createdAt;       // Block timestamp when this event was created
    }

    // -------------------------------------------------------------------------
    //  State
    // -------------------------------------------------------------------------

    /// @notice Full registry of all events ever created through this factory.
    EventInfo[] public allEvents;

    // -------------------------------------------------------------------------
    //  Events
    // -------------------------------------------------------------------------

    /// @notice Emitted every time a new event (SoulboundTicket contract) is created.
    event EventCreated(
        address indexed eventContract,
        address indexed organizer,
        string  eventName,
        uint256 eventDate,
        uint256 createdAt
    );

    // -------------------------------------------------------------------------
    //  Core � Create Event
    // -------------------------------------------------------------------------

    /**
     * @notice Create a new event and automatically deploy its SoulboundTicket contract.
     * @dev The caller (msg.sender) becomes the owner of the resulting SoulboundTicket,
     *      NOT this Factory contract  that is why _owner is passed explicitly.
     *
     * @param _eventName   Human-readable event name (e.g. "SoulTix 2026").
     * @param _tokenName   ERC721 token name (e.g. "SoulTix 2026 Ticket").
     * @param _tokenSymbol ERC721 token symbol (e.g. "SOUL").
     * @param _eventDate   Unix timestamp of the event. Must be in the future.
     * @param _ticketPrice Ticket price in wei (native BOT).
     * @param _maxSupply   Total ticket quota. Must be > 0.
     * @return addr Address of the newly deployed SoulboundTicket contract.
     */
    function createEvent(
        string memory _eventName,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _eventDate,
        uint256 _ticketPrice,
        uint256 _maxSupply
    ) external returns (address addr) {
        SoulboundTicket newTicket = new SoulboundTicket(
            msg.sender,  // _owner  � organizer's wallet, NOT the factory address
            _eventName,
            _tokenName,
            _tokenSymbol,
            _eventDate,
            _ticketPrice,
            _maxSupply
        );

        addr = address(newTicket);

        allEvents.push(EventInfo({
            contractAddress: addr,
            organizer:       msg.sender,
            eventName:       _eventName,
            eventDate:       _eventDate,
            createdAt:       block.timestamp
        }));

        emit EventCreated(addr, msg.sender, _eventName, _eventDate, block.timestamp);
    }

    // -------------------------------------------------------------------------
    //  View Functions
    // -------------------------------------------------------------------------

    /// @notice Returns the full registry of all events created through this factory.
    function getAllEvents() external view returns (EventInfo[] memory) {
        return allEvents;
    }

    /// @notice Total number of events registered in this factory.
    function getEventCount() external view returns (uint256) {
        return allEvents.length;
    }

    /**
     * @notice Returns only the events created by a specific organizer address.
     *         Used by the frontend "My Events" panel.
     * @param organizer Wallet address of the organizer to filter by.
     */
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

    /**
     * @notice Returns a paginated slice of all events (most recent first).
     *         Useful when there are many events and the frontend wants to paginate.
     * @param offset Starting index (0-based).
     * @param limit  Maximum number of events to return.
     */
    function getEventsPaginated(uint256 offset, uint256 limit)
        external
        view
        returns (EventInfo[] memory)
    {
        uint256 total = allEvents.length;
        if (offset >= total) return new EventInfo[](0);

        uint256 end = offset + limit;
        if (end > total) end = total;

        uint256 size = end - offset;
        EventInfo[] memory page = new EventInfo[](size);
        for (uint256 i = 0; i < size; i++) {
            // Return in reverse order (most recent first)
            page[i] = allEvents[total - 1 - offset - i];
        }
        return page;
    }
}
