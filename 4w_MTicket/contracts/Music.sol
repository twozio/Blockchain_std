// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "./MusicTicket.sol"; // Import MusicTicket contract

contract Music is ERC1155, ERC1155Receiver {
    MusicTicket public musicTicketContract; // Reference to the MusicTicket contract

    struct MusicInfo {
        uint id;
        string singerName;
        string composer;
        string lyricist;
        uint releaseDate;
    }

    string public name;
    string public symbol;

    uint private musicIndex = 1;
    mapping(uint => MusicInfo) private musicInfos;
    mapping(uint => address) private musicOwners; // Mapping to track music owners

    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Music/{id}.json") {
        name = "GNU MUSIC";
        symbol = "Guarantable";
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // This function is triggered when a single token is transferred to this contract 
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) 
        external 
        pure
        override 
        returns(bytes4) 
    {
        return this.onERC1155Received.selector; // Return the correct magic value
    }

    // This function is triggered when multiple tokens are transferred to this contract
    function onERC1155BatchReceived(address operator, address from, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) 
        external
        pure
        override 
        returns(bytes4) 
    {
        return this.onERC1155BatchReceived.selector; // Return the correct magic value
    }


    function setMusicTicketContract(address _musicTicketContract) public {
        musicTicketContract = MusicTicket(_musicTicketContract);
    }

    function mintMusic(string memory singerName, string memory composer, string memory lyricist, uint releaseDate) public {
        uint id = musicIndex++;
        musicInfos[id] = MusicInfo(id, singerName, composer, lyricist, releaseDate);
        musicOwners[id] = msg.sender;
        _mint(msg.sender, id, 1, "");
    }

    function mintTicket(uint musicId, uint price) public {
        require(musicId < musicIndex, "Music does not exist");
        require(musicOwners[musicId] == msg.sender, "Only the music owner can mint tickets");
        musicTicketContract.mintTicket(msg.sender, musicId, price);
    }

    function mintMusicAndTickets(string memory singerName, string memory composer, string memory lyricist, uint releaseDate, uint price) public {
        mintMusic(singerName, composer, lyricist, releaseDate);     // First, mint the music
        uint musicId = musicIndex - 1;                              // Get the id of the last minted music
        musicTicketContract.mintTicket(msg.sender, musicId, price); // Then mint tickets for this music
    }

    function sellTicket(uint ticketId, uint price) public {
        // Check that the caller owns the ticket they are trying to sell
        require(musicTicketContract.ownerOf(ticketId) == msg.sender, "You do not own this ticket");

        // Call the listTicketForSale function in the MusicTicket contract
        musicTicketContract.listTicketForSale(ticketId, price, msg.sender);
    }

    function buyListedTicket(uint ticketId) public payable {
        // Retrieve the listing price of the ticket
        uint ticketPrice = musicTicketContract.getTicketPrice(ticketId);
        require(ticketPrice > 0, "Ticket does not exist");

        // Check that the buyer sent enough ether
        require(msg.value >= ticketPrice, "Not enough ether sent");

        // Check that the contract is approved to transfer the ticket
        require(musicTicketContract.getApproved(ticketId) == ownerOf(ticketId), "Not approved to transfer this ticket");

        // Transfer the ether to the seller
        address seller = musicTicketContract.ownerOf(ticketId);
        payable(seller).transfer(ticketPrice);

        // Transfer the ticket to the buyer
        musicTicketContract.transferTicket(seller, msg.sender, ticketId);

        // Remove the ticket from the list of tickets for sale
        musicTicketContract.removeTicketFromSale(ticketId);
    }

    function streamMusic(uint ticketId) public {
        musicTicketContract.streamMusic(msg.sender, ticketId);
    }

    function downloadMusic(uint ticketId) public {
        musicTicketContract.downloadMusic(msg.sender, ticketId);
    }

    function getMusicInfo(uint id) public view returns (MusicInfo memory) {
        return musicInfos[id];
    }

    function ownerOf(uint id) public view returns (address) {
        return musicOwners[id]; // Return the music owner
    }

    function getTicketInfo(uint ticketId) public view returns (MusicTicket.TicketInfo memory) {
        return musicTicketContract.getTicketInfo(ticketId);
    }
}