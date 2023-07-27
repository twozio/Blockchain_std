// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ticket1155 is ERC1155, Ownable {
    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/erc1155/{id}.json") {}

    struct TicketInfo {
        uint id;                // @param 토큰 Id
        uint limitTime;         // @param 티켓 만료 시간
        uint price;             // @param 티켓 가격
        uint maxTicket;         // @param 티켓 생성 최대치
        string name;            // @param 티켓 이름
    }
    
    uint256 private ticketIndex = 1;
    mapping(uint256 => TicketInfo) private tickets;

    function mintTicket(uint limitTime, uint price, uint maxTicket, uint amounts, string memory name) public onlyOwner {
        TicketInfo memory newTicket = TicketInfo({
            id: ticketIndex,
            limitTime: limitTime,
            price: price,
            maxTicket: maxTicket,
            name: name
        });
        tickets[ticketIndex] = newTicket;
        _mint(msg.sender, ticketIndex, amounts, "");
        ticketIndex++;
    }

    function buyTickets(uint256[] memory ids, uint256[] memory amounts) public payable {
        require(ids.length == amounts.length, "Mismatched ids and amounts");

        uint totalCost = 0;
        for(uint i = 0; i < ids.length; i++) {
            require(tickets[ids[i]].maxTicket <= amounts[i], "Do not buy too many tickets");
            totalCost += tickets[ids[i]].price * amounts[i];
        }

        require(msg.value >= totalCost, "Not enough Ether");

        for(uint i = 0; i < ids.length; i++) {
            _safeTransferFrom(owner(), msg.sender, ids[i], amounts[i], "");
        }
    }

    function buyTicket(uint256 id, uint256 amount) public payable {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = id;
        amounts[0] = amount;
        buyTickets(ids, amounts);
    }

    function useTicket(uint256 id) public {
        require(balanceOf(msg.sender, id) > 0, "No ticket to use");
        require(block.timestamp <= tickets[id].limitTime, "Ticket expired");
        _burn(msg.sender, id, 1);
    }

    function getTicketInfo(uint256 id) public view returns (string memory name, uint limitTime, uint price, uint maxTicket) {
        require(
            msg.sender == owner() || balanceOf(msg.sender, id) > 0,
            "Cannot query this ticket"
        );
        if (msg.sender == owner()) {
            return (
                tickets[id].name, 
                tickets[id].limitTime, 
                tickets[id].price, 
                tickets[id].maxTicket
            );
        } else {
            return (
                tickets[id].name, 
                tickets[id].limitTime, 
                0, 
                0
            );
        }
    }
}