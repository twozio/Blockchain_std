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

    uint private ticketIndex = 1;
    mapping(uint => TicketInfo) private ticketInfos;

    constructor(address _musicContract) ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Music/Ticket.json") {
        musicContract = Music(_musicContract);
    }

    // Mint a new music ticket
    function mintTicket(uint musicId, uint price, uint amount) public {
        require(msg.sender == musicContract.ownerOf(musicId), "Only the owner of the music can mint a ticket");

        uint downloadLimit = 20;
        uint streamLimit = 500;
        uint expiryDate = block.timestamp + 2592000;

        TicketInfo memory newTicket = TicketInfo(musicId, expiryDate, downloadLimit, streamLimit, price);
        ticketInfos[ticketIndex] = newTicket;

        _mint(msg.sender, ticketIndex, amount, "");
        ticketIndex++;
    }
    
    function buyTickets(uint[] memory ticketIds, uint[] memory amount) public {

    }
    // Purchase a music ticket
    function buyTicket(uint ticketId) public payable {
        require(msg.value == ticketInfos[ticketId].price, "Incorrect price paid");
        require(msg.sender != musicContract.ownerOf(ticketInfos[ticketId].musicId), "Owner cannot purchase their own ticket");

        address musicOwner = musicContract.ownerOf(ticketInfos[ticketId].musicId);
        payable(musicOwner).transfer(msg.value); // Transfer Ether directly to the owner of the music

        _safeTransferFrom(musicContract.ownerOf(ticketId), msg.sender, ticketId, 1, "");
    }

    // Get ticket information
    function getTicketInfo(uint ticketId) public view returns (TicketInfo memory) {
        return ticketInfos[ticketId];
    }

    function getMusicTicketInfo(uint ticketId) public view returns (TicketInfo memory) {

    }
    

    function downlaodMusic(uint ticketId) public {

    }

    function streamMusic(uint ticketId) public {

    }

}