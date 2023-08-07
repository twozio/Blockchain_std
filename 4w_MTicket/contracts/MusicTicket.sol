// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Music.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MusicTicket is ERC1155 {
    Music public musicContract; // Reference to the Music contract

    struct TicketInfo {
        uint musicId; // Reference to the corresponding music ID
        uint expiryDate; // Expiration date for the ticket
        uint downloadLimit; // Limit on the number of downloads
        uint streamLimit; // Limit on the number of streams
        uint price; // Price of the ticket
    }

    modifier onlyMusicContract() {
        require(msg.sender == address(musicContract), "Only the Music contract can call this function");
        _;
    }

    uint private ticketIndex = 1;
    mapping(uint => TicketInfo) private ticketInfos;

    constructor(address _musicContract) ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Music/Ticket.json") {
        musicContract = Music(_musicContract);
    }

    // Mint a new music ticket
    function mintTicket(uint musicId, uint price, uint amount) public onlyMusicContract {
        require(msg.sender == address(musicContract), "Only the music can mint a ticket");

        uint downloadLimit = 20;
        uint streamLimit = 500;
        uint expiryDate = block.timestamp + 2592000;

        TicketInfo memory newTicket = TicketInfo(musicId, expiryDate, downloadLimit, streamLimit, price);
        ticketInfos[ticketIndex] = newTicket;

        _mint(msg.sender, ticketIndex, amount, "");
        ticketIndex++;
    }
    // Purchase a music ticket
    function buyTickets(uint[] memory ticketIds, uint[] memory amounts) public payable onlyMusicContract {
        require(ticketIds.length == amounts.length, "Mismatch in ticketIds and amounts");
        require(ticketIds.length > 0, "Must purchase at least one ticket");

        uint totalCost = 0;

        // Calculate the total cost for all tickets
        for (uint i = 0; i < ticketIds.length; i++) {
            uint ticketId = ticketIds[i];
            uint amount = amounts[i];
            require(ticketInfos[ticketId].price > 0, "Ticket does not exist");
            require(msg.sender != musicContract.ownerOf(ticketInfos[ticketId].musicId), "Owner cannot purchase their own ticket");

            totalCost += ticketInfos[ticketId].price * amount;
        }

        // Ensure enough funds were sent
        require(msg.value == totalCost, "Incorrect price paid");

        // Transfer the tickets and send Ether to the music owners
        for (uint i = 0; i < ticketIds.length; i++) {
            uint ticketId = ticketIds[i];
            uint amount = amounts[i];

            address musicOwner = musicContract.ownerOf(ticketInfos[ticketId].musicId);
            payable(musicOwner).transfer(ticketInfos[ticketId].price * amount); // Transfer Ether to the owner of the music

            _safeTransferFrom(address(this), msg.sender, ticketId, amount, ""); // Transfer the tickets
        }
    }
    // Get ticket information
    function getTicketInfo(uint ticketId) public view onlyMusicContract returns (TicketInfo memory) {
        return ticketInfos[ticketId];
    }

    function downloadMusic(uint ticketId) public onlyMusicContract {
        require(balanceOf(msg.sender, ticketId) > 0, "Caller does not own a ticket");
        require(block.timestamp <= ticketInfos[ticketId].expiryDate, "This Ticket is expired!");
        require(ticketInfos[ticketId].downloadLimit > 0, "You don't have any download chance!");

        ticketInfos[ticketId].downloadLimit--;
    }

    function streamMusic(uint ticketId) public onlyMusicContract {
        require(balanceOf(msg.sender, ticketId) > 0, "Caller does not own a ticket");
        require(block.timestamp <= ticketInfos[ticketId].expiryDate, "This Ticket is expired!");
        require(ticketInfos[ticketId].streamLimit > 0, "You don't have any streaming chance!");

        ticketInfos[ticketId].streamLimit--;
    }

}