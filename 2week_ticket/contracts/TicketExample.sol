// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

// 1688137200 : 2023-07-01 00:00:00
// 1690729200 : 2023-07-31 00:00:00

contract TicketExample is ERC721 {
    //ERC 721 생성자 함수 실행 ERC721(_name, _symbol)
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol){}

    struct Ticket {
        uint useNum;        // 사용횟수
        uint startTime;     // 유효기간
        uint endTime;
        uint price;         // 가격
        string seatNum;     // 좌석번호
    }

    Ticket[] public tickets;
    mapping(uint => bool) private _tokenExist;
    mapping(uint => bool) private _tokenStatus;

    function mintTickets (
        uint[] memory useNum,
        uint[] memory startTime,
        uint[] memory endTime,
        uint[] memory price,
        string[] memory seatNum,
        uint _tokenId 
    ) public {
        
    }



}