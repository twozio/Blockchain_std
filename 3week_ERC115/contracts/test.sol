// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TicketSystem is ERC1155, Ownable {
    uint256 public constant MAX_QUERY = 10; // Maximum tickets a buyer can query
    uint256 private ticketIndex = 0;
    mapping(uint256 => string) private ticketData; // Additional data about each ticket

    constructor() ERC1155("https://my.api/ticket/{id}.json") {}

    function mint(string memory data) public onlyOwner {
        ticketData[ticketIndex] = data;
        _mint(msg.sender, ticketIndex, 1, "");
        ticketIndex++;
    }

    function buy(uint256 id) public payable {
        require(msg.value >= 1 ether, "Not enough Ether"); // Assuming 1 Ether per ticket
        safeTransferFrom(owner(), msg.sender, id, 1, "");
    }

    function useTicket(uint256 id) public {
        require(balanceOf(msg.sender, id) > 0, "No ticket to use");
        _burn(msg.sender, id, 1);
    }

    function getTicketData(uint256 id) public view returns (string memory) {
        require(
            msg.sender == owner() || balanceOf(msg.sender, id) > 0,
            "Cannot query this ticket"
        );
        return ticketData[id];
    }

    function getMultipleTicketsData(uint256[] memory ids)
        public
        view
        returns (string[] memory)
    {
        require(
            msg.sender == owner() || ids.length <= MAX_QUERY,
            "Too many tickets to query"
        );
        string[] memory data = new string[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            data[i] = getTicketData(ids[i]);
        }
        return data;
    }
}
