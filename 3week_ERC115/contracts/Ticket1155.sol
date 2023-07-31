// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Ticket1155 is ERC1155, Ownable {
    
    string public name;
    string public symbol;
    
    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/erc1155/{id}.json") {
        name = "Chunsic";
        symbol = "Guarantable";
    }

    struct TicketInfo {
        uint id;                // @param 토큰 Id
        uint limitTime;         // @param 티켓 만료 시간
        uint price;             // @param 티켓 가격
        uint limitAmount;       // @param 티켓 구매 가능 수 
        string ticketName;            // @param 티켓 이름
    }
    
    uint maxTicket = 100;
    uint private ticketIndex = 1;
    mapping(uint => TicketInfo) private tickets;

    function getTicketIndex() public view returns (uint) {
        return ticketIndex;
    }

    function mintTicket(uint limitTime, uint price, uint limitAmount,uint amounts, string memory ticketName) public onlyOwner {
        require(amounts <= maxTicket, "You can mint under amount 100");
        TicketInfo memory newTicket = TicketInfo({
            id: ticketIndex,
            limitTime: limitTime,
            price: price,
            limitAmount: limitAmount,
            ticketName: ticketName
        });
        tickets[ticketIndex] = newTicket;
        _mint(msg.sender, ticketIndex, amounts, "");
        ticketIndex++;
    }

    function buyTickets(uint[] memory ids, uint[] memory amounts) public payable {
        require(ids.length == amounts.length, "Mismatched ids and amounts");

        uint totalCost = 0;
        for(uint i = 0; i < ids.length; i++) {
            require(tickets[ids[i]].limitAmount >= amounts[i], "Do not buy too many tickets");
            totalCost += tickets[ids[i]].price * amounts[i];
        }

        require(msg.value >= totalCost, "Not enough Ether");

        for(uint i = 0; i < ids.length; i++) {
            _safeTransferFrom(owner(), msg.sender, ids[i], amounts[i], "");
        }
    }

    function buyTicket(uint id, uint amount) public payable {
        uint[] memory ids = new uint[](1);
        uint[] memory amounts = new uint[](1);
        ids[0] = id;
        amounts[0] = amount;
        buyTickets(ids, amounts);
    }

    function useTicket(uint256 id) public {
        require(balanceOf(msg.sender, id) > 0, "No ticket to use");
        require(block.timestamp <= tickets[id].limitTime, "Ticket expired");
        _burn(msg.sender, id, 1);
    }

    function getTicketInfo(uint256 id) public view returns (string memory ticketName, uint limitTime, uint price, uint limitAmount) {
        require(
            msg.sender == owner() || balanceOf(msg.sender, id) > 0,
            "Cannot query this ticket"
        );
        if (msg.sender == owner()) {
            return (
                tickets[id].ticketName, 
                tickets[id].limitTime, 
                tickets[id].price, 
                tickets[id].limitAmount
            );
        } else {
            return (
                tickets[id].ticketName, 
                tickets[id].limitTime, 
                0, 
                0
            );
        }
    }
}