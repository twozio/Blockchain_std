// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./DownloadTicket.sol";

contract Copyright is ERC721URIStorage {
    DTicket public Dt;
    address public owner;

    string productNumber = "";
    string uri = "https://your_base_url/product/";          // It will be work like a baseURI.
    mapping(uint => bool) private copyrightAvailable;       // Manage for copyright state.
    mapping(uint => uint[]) public copyrightTickets;        // Copyright link to ticket for management.

    constructor() ERC721("3DStore", productNumber) {
        owner = msg.sender;
    }

    /**
     * @dev After deploy, you need to call this function and set the DownloadTicket.sol address.
     */
    function setDtAddress(address _DtAddress) public {
        Dt = DTicket(_DtAddress);
    }
    // You can change the copyright metadata URI.
    function resetURI(string memory _URI) public {
        uri = _URI;
    }
    // Copyright NFT minting.
    function mintCopyright(uint tokenId, string memory _productNumber) public {
        copyrightAvailable[tokenId] = true;
        productNumber = _productNumber;

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(uri, tokenId)));
    }
    // Download ticket minting.
    function mintDownloadTicket(uint copyrightId, uint counter, uint price) public {
        require(msg.sender == ownerOf(copyrightId), "Only Copyright owner can mint the tickets");

        uint newTicketId = Dt.mintTicket(msg.sender, copyrightId, counter, price);
        // For management.
        copyrightTickets[copyrightId].push(newTicketId);
    }
    // Buy download ticket.
    function buyTicket(uint ticketId) public payable {
        uint copyrightId = Dt.getCopyrightId(ticketId);
        // Check the ticket available.
        require(isAvailable(copyrightId), "The corresponding Copyright NFT is not available");

        uint ticketPrice = Dt.getTicketPrice(ticketId);
        require(ticketPrice > 0, "Ticket does not exist");

        require(msg.value >= ticketPrice, "Not enough ether sent");
        // payment
        address seller = Dt.ownerOf(ticketId);
        payable(seller).transfer(ticketPrice);
        // Transfer ticket NFT to customer
        Dt.transferTicket(seller, msg.sender, ticketId);
    }

    function downloadTicket(uint ticketId) public {
        Dt.download(msg.sender, ticketId);
    }
    // Change copyright available. You can stop or start the sale.
    function setAvailable(uint copyrightId, bool available) public {
        require(msg.sender == ownerOf(copyrightId), "Only the Copyright owner can set availability");
        copyrightAvailable[copyrightId] = available;
    }
    // Check the ticket available.
    function isAvailable(uint copyrightId) public view returns (bool) {
        return copyrightAvailable[copyrightId];
    }
}