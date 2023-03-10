// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IZicket.sol";
import "./CredentialVerifier.sol";
import "./EventTicket.sol";

contract Zicket is IZicket, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    CredentialVerifier public credentialVerifier;
    EventTicket public eventTicket;
    mapping(uint256 => Event) public events;
    Counters.Counter public totalEvents;
    
    /** 
    * @notice The event start or end date must be in feature.
    */
    error IvalidEventDate();

    /** 
    * @notice The event ticket price can't be zero or less.
    */
    error InvalidTicketPrice();

    /**
    * @notice The desired event does not exist.
    */
    error NotFoundEvent();

    /**
    * @notice The desired event does not open for entering anymore.
    */
    error NotActiveEvent();

    /**
    * @notice The user send invalid amount.
    */
    error InvalidAmount();

    /**
    * @notice The user address is invalid.
    */
    error NotValidAddress();

    constructor(CredentialVerifier _credentialVerifier, EventTicket _eventTicket) {
        credentialVerifier = _credentialVerifier;
        eventTicket = _eventTicket;
    }
    
    function addNewEvent(address payable eventOwner, uint256 ticketPrie, uint256 totalAmountReceived, uint256 eventStart, uint256 eventEnd, string memory name, string memory descripton, string memory ticketTokenURI) public override onlyOwner {
        if(eventStart <= block.timestamp) {
            revert IvalidEventDate();
        }
        if(eventEnd <= block.timestamp) {
            revert IvalidEventDate();
        }
        if(eventStart > eventEnd) {
            revert IvalidEventDate();
        }
        if(ticketPrie <= 0) {
            revert InvalidTicketPrice();
        }
        Event memory newEvent = Event(eventOwner, ticketPrie, totalAmountReceived, eventStart, eventEnd, name, descripton, ticketTokenURI);
        uint256 currentEventId = totalEvents.current();
        events[currentEventId] = newEvent;
        totalEvents.increment();

        emit EventCreation(msg.sender, currentEventId, newEvent);
    }

    function userVerification(uint256 eventId, UserData memory userData, uint64 requestId, uint256[] calldata inputs) public override {
        if(eventId > totalEvents.current()) {
            revert NotFoundEvent();
        }
        if(isEventTicketingClosed(eventId)) {
            revert NotActiveEvent();
        }
        credentialVerifier.submitProofRequest(userData.did, userData.hashedPrivKey, requestId, inputs);

        emit Verified(msg.sender, userData.did);
    }

    function purchaseTicket(uint256 eventId, address ticketDestinationAddress) public override payable nonReentrant{
        require(eventId <= totalEvents.current(), "The event does not exist.");
        require(!isEventTicketingClosed(eventId), "The event is not open for entering anymore.");
        if(ticketDestinationAddress == address(0)) {
            revert NotValidAddress();
        }
        Event memory currentEvent = events[eventId];
        if(msg.value < 0 || msg.value < currentEvent.ticketPrice) {
            revert InvalidAmount();
        }
        currentEvent.totalAmountReceived += msg.value;
        sendTicket(currentEvent.ticketTokenURI, ticketDestinationAddress);
    }

    /**
    * @dev Check if event is open for selling tickets
    * @param eventId The id of the event for purchase ticket
    * @return closed The boolean value if the selling ticket is finished
    */
    function isEventTicketingClosed(uint256 eventId) private view returns (bool closed) {
        Event memory currentEvent = events[eventId];
        closed = (currentEvent.eventStart >= block.timestamp && currentEvent.eventEnd >= block.timestamp);
    }

    /**
    * @dev Send the ticket SBT to user.
    * @param ticketTokenURI The event ticket uri of SBT.
    * @param ticketDestinationAddress The address where to send ticket.
    */
    function sendTicket(string memory ticketTokenURI, address ticketDestinationAddress) private {
        uint256 ticketId = eventTicket.awardTicket(ticketTokenURI, ticketDestinationAddress);

        emit TicketSBT(ticketId, ticketDestinationAddress);  
    }
}
