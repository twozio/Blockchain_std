// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// 1688137200 : 2023-07-01 00:00:00
// 1690729200 : 2023-07-31 00:00:00

contract Ticket is ERC721URIStorage, Ownable {
    using SafeMath for uint;
    //ERC 721 생성자 함수 실행 ERC721(_name, _symbol)
    constructor() ERC721("EventTicket", "ETKT"){}
    event ticketuse(uint tokenId);

    struct TicketInfo {
        uint startTime;     // 유효기간
        uint endTime;
        uint uses;          // 사용횟수
        uint price;         // 가격
        string seatNumber;  // 좌석번호
        bool active;        // 상태
    }

    mapping(uint => TicketInfo) private _tickets;

    function mintTicket(
        address to, 
        uint tokenId, 
        uint startTime, 
        uint endTime, 
        uint uses,
        uint price,
        string memory seatNumber,
        string memory tokenURI
    ) public onlyOwner {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tickets[tokenId] = TicketInfo(startTime, endTime, uses, price, seatNumber, true);
    }

    function buyTicket(uint256 tokenId) public payable {
        require(msg.value == _tickets[tokenId].price, "Incorrect value sent");
        require(_tickets[tokenId].active, "Ticket is not active");
        // address currentOwner = ownerOf(tokenId);
        _transfer(owner(), msg.sender, tokenId);
    }

    function burnTicket(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: burn caller is not owner nor approved");
        _burn(tokenId);
        delete _tickets[tokenId];
    }

    function getTicketInfo(uint256 tokenId) public view returns (TicketInfo memory) {
        return _tickets[tokenId];
    }

    function useTicket(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not owner nor approved");
        require(_tickets[tokenId].active, "Ticket is not active");
        require(block.timestamp >= _tickets[tokenId].startTime && block.timestamp <= _tickets[tokenId].endTime, "Ticket is not in valid period");

        _tickets[tokenId].uses = _tickets[tokenId].uses - 1;
        emit ticketuse(tokenId);
        
        if (_tickets[tokenId].uses == 0) {
            _tickets[tokenId].active = false;
        }
    }

    // to withdraw the collected Ether
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}