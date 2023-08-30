// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Music.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MusicTicket is ERC721URIStorage {
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

    constructor() ERC721("GNU MUSIC", "Guarantable") {}

    function setMusicContract(address _musicContract) public {
        musicContract = Music(_musicContract);
    }

    function approveMusicContract() public {
        setApprovalForAll(address(musicContract), true);
    }
    // Mint a new music ticket
    function mintTicket(address recipient, uint musicId, uint price) public onlyMusicContract {
        uint downloadLimit = 20;
        uint streamLimit = 500;
        uint expiryDate = block.timestamp + 2592000;

        ticketInfos[ticketIndex] = TicketInfo(musicId, expiryDate, downloadLimit, streamLimit, price);

        // Mint the token
        _mint(recipient, ticketIndex);
        
        // Set the token URI
        _setTokenURI(ticketIndex, "https://dev-internship.s3.ap-northeast-2.amazonaws.com/Ticket/1.json");

        ticketIndex++;
    }

    function transferTicket(address musicOwner, address recipient, uint ticketId) public onlyMusicContract {
        require(_isApprovedOrOwner(address(musicContract), ticketId), "Music contract is not approved to manage tickets");
        
        _transfer(musicOwner, recipient, ticketId);
    }

    function getTotalCost(uint ticketId) public view returns (uint) {
        return ticketInfos[ticketId].price;
    }

    // Get ticket information
    function getTicketInfo(uint ticketId) public view returns (TicketInfo memory) {
        return ticketInfos[ticketId];
    }

    function downloadMusic(address recipient, uint ticketId) public onlyMusicContract {
        require(_exists(ticketId), "Ticket does not exist");
        require(ownerOf(ticketId) == recipient, "Caller does not own a ticket");
        require(block.timestamp <= ticketInfos[ticketId].expiryDate, "This Ticket is expired!");
        require(ticketInfos[ticketId].downloadLimit > 0, "You don't have any download chance!");

        ticketInfos[ticketId].downloadLimit--;
    }

    function streamMusic(address recipient, uint ticketId) public onlyMusicContract {
        require(_exists(ticketId), "Ticket does not exist");
        require(ownerOf(ticketId) == recipient, "Caller does not own a ticket");
        require(block.timestamp <= ticketInfos[ticketId].expiryDate, "This Ticket is expired!");
        require(ticketInfos[ticketId].streamLimit > 0, "You don't have any streaming chance!");

        ticketInfos[ticketId].streamLimit--;
    }
}