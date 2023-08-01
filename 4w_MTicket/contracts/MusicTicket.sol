// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Music.sol";

contract MusicTicket is ERC1155 {
    Music private musicContract; // Reference to the Music contract

    struct Ticket {
        uint id;
        uint musicId;
        address owner;
        // Additional attributes
    }

    uint private ticketIndex = 1;
    mapping(uint => Ticket) private tickets;

    constructor(address _musicContract) ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Music/{id}.json") {
        musicContract = Music(_musicContract);
    }

    // Event to notify when a new music ticket is minted
    event TicketMinted(uint indexed id, uint indexed musicId, address indexed owner);

    // Function to mint a new music ticket
    function mintTicket(uint musicId) public returns (uint) {
        // Verify that the caller is the owner of the specified music item in the Music contract
        require(musicContract.balanceOf(msg.sender, musicId) > 0, "Not the owner of the specified music item");

        uint id = ticketIndex;
        tickets[id] = Ticket({
            id: id,
            musicId: musicId,
            owner: msg.sender
            // Additional attributes
        });
        _mint(msg.sender, id, 1, "");
        ticketIndex++;
        emit TicketMinted(id, musicId, msg.sender);
        return id;
    }

    // Additional functions to manage or interact with music tickets
}
