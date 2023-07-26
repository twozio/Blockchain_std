// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Ticket1155 is ERC1155 {
    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/erc1155/{id}.json") {}

    struct TicketInfo {
        uint id;            // @param 메타데이터 Id
        uint limitTime;     // @param 유효기간
        uint price;         // @param 가격
        uint maxTicket;     // @param 최대 티켓 수
        string name;        // @param 이름
    }

}