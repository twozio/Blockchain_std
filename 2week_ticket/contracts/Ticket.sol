// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @notice 1688137200 : 2023-07-01 00:00:00
// @notice 1690729200 : 2023-07-31 00:00:00

contract Ticket is ERC721URIStorage, Ownable {
    // @dev ERC 721 생성자 함수 실행 ERC721(_name, _symbol)
    constructor() ERC721("EventTicket", "ETKT"){}
    event ticketuse(uint tokenId);

    struct TicketInfo {
        uint startTime;     // @param 유효기간
        uint endTime;
        uint uses;          // @param 사용횟수
        uint price;         // @param 가격
        string seatNumber;  // @param 좌석번호
        bool active;        // @param 상태
    }

    mapping(uint => TicketInfo) private _tickets;
    mapping(address => uint) public pendingWithdrawals;

    function mintTicket(    // 티켓 민팅
        address to, 
        uint tokenId, 
        uint32 startTime, 
        uint32 endTime, 
        uint8 uses,
        uint price,
        string memory seatNumber,
        string memory tokenURI
    ) public onlyOwner {
        _mint(to, tokenId); 
        _setTokenURI(tokenId, tokenURI);
        _tickets[tokenId] = TicketInfo(startTime, endTime, uses, price, seatNumber, true);
    }

    function buyTicket(uint256 tokenId) external payable {          // 티켓 구매
        require(msg.value == _tickets[tokenId].price, "Incorrect value sent");
        require(_tickets[tokenId].active, "Ticket is not active");  // 상태 확인
        (bool success, ) = payable(ownerOf(tokenId)).call{value: msg.value}("");
        require(success, "Transfer failed");
        _transfer(ownerOf(tokenId), msg.sender, tokenId);           // owner에게 직접전송
    }

    function burnTicket(uint256 tokenId) public {                   // 티켓 삭제
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: burn caller is not owner nor approved");
        _burn(tokenId);
        delete _tickets[tokenId];
    }

    function getTicketInfo(uint256 tokenId) public view returns (TicketInfo memory) {
        return _tickets[tokenId];
    }

    function useTicket(uint256 tokenId) public {                    // 티켓 사용
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not owner nor approved");
        require(_tickets[tokenId].active, "Ticket is not active");
        require(block.timestamp >= _tickets[tokenId].startTime && block.timestamp <= _tickets[tokenId].endTime, "Ticket is not in valid period");
        // 티켓 유효기간 확인
        _tickets[tokenId].uses = _tickets[tokenId].uses - 1;        // 티켓 사용 횟수 감소
        emit ticketuse(tokenId);
        
        if (_tickets[tokenId].uses == 0) {
            _tickets[tokenId].active = false;
        }
    }
}