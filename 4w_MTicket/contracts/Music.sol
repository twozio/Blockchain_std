// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./MusicTicket.sol"; // Import MusicTicket contract

contract Music is ERC1155 {
    MusicTicket public musicTicketContract; // Reference to the MusicTicket contract

    struct MusicInfo {
        uint id;
        string singerName;
        string composer;
        string lyricist;
        uint releaseDate;
    }

    uint private musicIndex = 1;
    mapping(uint => MusicInfo) private musicInfos;
    mapping(uint => address) private musicOwners; // Mapping to track music owners

    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Music/{id}.json") {}

    function mintMusic(string memory singerName, string memory composer, string memory lyricist, uint releaseDate, uint price, uint amount) public {
        uint id = musicIndex++;
        musicInfos[id] = MusicInfo(id, singerName, composer, lyricist, releaseDate);
        musicOwners[id] = msg.sender;
        _mint(msg.sender, id, 1, "");

        // Mint corresponding tickets
        musicTicketContract.mintTicket(id, price, amount);
    }

    function getMusicInfo(uint id) public view returns (MusicInfo memory) {
        return musicInfos[id];
    }

    function ownerOf(uint id) public view returns (address) {
        return musicOwners[id]; // Return the music owner
    }
}
