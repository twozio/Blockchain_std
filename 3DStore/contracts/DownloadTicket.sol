// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Copyright.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract DTicket is ERC721URIStorage {
    Copyright public Cp;

    modifier onlyCopyrightContract() {
        require(msg.sender == address(Cp), "Only the Music contract can call this function");
        _;
    }

    uint private ticketIndex = 1;
    mapping(uint => uint) public ticketToCopyright;
    mapping(uint => uint) public downloadCounter;

    constructor() ERC721("Download Ticket", "DT") {} 


    function mintTicket(uint copyrightId, uint counter) public onlyCopyrightContract returns (uint) {
        ticketToCopyright[ticketIndex] = copyrightId;
        downloadCounter[ticketIndex] = counter;

        _mint(msg.sender, ticketIndex);
        _setTokenURI(ticketIndex, string(abi.encodePacked("https://your_base_url/tickets/", ticketIndex)));

        return ticketIndex;
    }

}