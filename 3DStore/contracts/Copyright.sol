// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./DownloadTicket.sol";

contract Copyright is ERC721URIStorage {
    DTicket public Dt;

    string product = "Empty";
    uint private copyrightIndex = 1;
    mapping(uint => bool) private copyrightAvailable;
    mapping(uint => uint[]) public copyrightTickets;
    mapping(uint => address) private musicOwners;

    constructor() ERC721("3DStore", product) {}

    /**
     * @dev This function must be called first, then the mintCopyright function.
     */
    function setProductNumber (string memory productNumber) public {
        product = productNumber;
    }

    function mintCopyright () public {
        copyrightAvailable[copyrightIndex] = true;

        _mint(msg.sender, copyrightIndex);
        _setTokenURI(copyrightIndex, string(abi.encodePacked("https://your_base_url/product/", copyrightIndex)));      // Example

        copyrightIndex++;
    }

    function mintDownloadTicket(uint copyrightId, uint counter) public {
        require(msg.sender == ownerOf(copyrightId), "Only Copyright owner can mint the tickets");

        uint newTicketId = Dt.mintTicket(copyrightId, counter);
        
        copyrightTickets[copyrightId].push(newTicketId);
    }

    function buyTicket(uint ticketId) public payable {

    }

    function setAvailable(uint copyrightId, bool available) public {
        copyrightAvailable[copyrightId] = available;
    }

    function isAvailable(uint copyrightId) public view returns (bool) {
        return copyrightAvailable[copyrightId];
    }

}