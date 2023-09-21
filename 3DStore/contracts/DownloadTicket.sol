// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Copyright.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract DTicket is ERC721URIStorage {
    Copyright public Cp;

    struct TicketInfo {
        uint copyrightId;
        uint downloadCounter;
        uint price;
    }
    // Only Copyright.sol can call some functions.
    modifier onlyCopyrightContract() {
        require(msg.sender == address(Cp), "Only the Music contract can call this function");
        _;
    }

    uint private ticketIndex = 1;
    mapping(uint => TicketInfo) public ticketInfos;
    /**
     * @dev You must deploy the copyright contract first.
     */
    constructor(address _cpAddress) ERC721("Download Ticket", "DT") {
        Cp = Copyright(_cpAddress);
    } 
    // Get the information that copyright's ticket.
    function getCopyrightId(uint ticketId) public view returns (uint) {
        require(_exists(ticketId), "Ticket does not exist");
        return ticketInfos[ticketId].copyrightId;
    }
    // Get ticket price.
    function getTicketPrice(uint ticketId) public view returns (uint) {
        return ticketInfos[ticketId].price;
    }
    // Transfer ticket to customer. This function can only be called by a copyright contract.
    function transferTicket(address ticketOwner, address recipient, uint ticketId) public onlyCopyrightContract {
        transferFrom(ticketOwner, recipient, ticketId);
    }
    // Download ticket minting. This function can only be called by a copyright contract.
    function mintTicket(address recipient, uint copyrightId, uint counter, uint price) public onlyCopyrightContract returns (uint) {
        ticketInfos[ticketIndex] = TicketInfo(copyrightId, counter, price);

        _mint(recipient, ticketIndex);
        _setTokenURI(ticketIndex, string(abi.encodePacked("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Ticket/1.json", ticketIndex)));

        ticketIndex++;
        return ticketIndex - 1;
    }
    // Ticket use.
    function download(address recipient, uint ticketId) public onlyCopyrightContract {
        require(_exists(ticketId), "Ticket does not exist");
        require(ownerOf(ticketId) == recipient, "Caller does not own a ticket");
        require(ticketInfos[ticketId].downloadCounter > 0, "You don't have any download chance!");

        ticketInfos[ticketId].downloadCounter--;
    }

}