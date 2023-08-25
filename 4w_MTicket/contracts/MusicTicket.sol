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

    string public name;
    string public symbol;

    modifier onlyMusicContract() {
        require(msg.sender == address(musicContract), "Only the Music contract can call this function");
        _;
    }

    uint private ticketIndex = 1;
    mapping(uint => TicketInfo) private ticketInfos;
    mapping(uint => uint) public ticketSupply;
    mapping(uint => mapping(address => uint)) public ticketDownloadLimits;
    mapping(uint => mapping(address => uint)) public ticketStreamLimits;

    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Ticket/{id}.json") {
        name = "GNU MUSIC";
        symbol = "Guarantable";
    }

    function setMusicContract(address _musicContract) public {
        musicContract = Music(_musicContract);
    }

    function approveMusicContract() public {
        setApprovalForAll(address(musicContract), true);
    }
    // Mint a new music ticket
    function mintTicket(address recipient, uint musicId, uint price, uint amount) public onlyMusicContract {
        uint downloadLimit = 20;
        uint streamLimit = 500;
        uint expiryDate = block.timestamp + 2592000;

        TicketInfo memory newTicket = TicketInfo(musicId, expiryDate, downloadLimit, streamLimit, price);
        ticketInfos[ticketIndex] = newTicket;
        ticketSupply[ticketIndex] = amount;

        // Initialize individual limits for the recipient
        ticketDownloadLimits[ticketIndex][recipient] = downloadLimit;
        ticketStreamLimits[ticketIndex][recipient] = streamLimit;

        _mint(recipient, ticketIndex, amount, "");
        ticketIndex++;
    }

    function transferTicket(address musicOwner, address recipient, uint ticketId, uint amount) public onlyMusicContract {
        require(isApprovedForAll(musicOwner, address(musicContract)), "Music contract is not approved to manage tickets");
        require(ticketSupply[ticketId] >= amount, "Not enough tickets in supply");
        
        ticketSupply[ticketId] -= amount;
        
        _safeTransferFrom(musicOwner, recipient, ticketId, amount, "");
    }

    function getTotalCost(uint ticketId, uint amount) public view returns (uint) {
        uint totalCost = ticketInfos[ticketId].price * amount;
        return totalCost;
    }

    function getAvailableTickets(uint ticketId) public view returns (uint) {
        return ticketSupply[ticketId];
    }

    // Get ticket information
    function getTicketInfo(uint ticketId) public view returns (TicketInfo memory) {
        return ticketInfos[ticketId];
    }

    function downloadMusic(address recipient, uint ticketId) public onlyMusicContract {
        require(balanceOf(recipient, ticketId) > 0, "Caller does not own a ticket");
        require(block.timestamp <= ticketInfos[ticketId].expiryDate, "This Ticket is expired!");
        require(ticketDownloadLimits[ticketId][recipient] > 0, "You don't have any download chance!");

        ticketDownloadLimits[ticketId][recipient]--;
    }

    function streamMusic(address recipient, uint ticketId) public onlyMusicContract {
        require(balanceOf(recipient, ticketId) > 0, "Caller does not own a ticket");
        require(block.timestamp <= ticketInfos[ticketId].expiryDate, "This Ticket is expired!");
        require(ticketStreamLimits[ticketId][recipient] > 0, "You don't have any streaming chance!");

        ticketStreamLimits[ticketId][recipient]--;
    }
}