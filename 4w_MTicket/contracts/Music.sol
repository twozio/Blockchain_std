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

    uint private musicIndex = 0;
    mapping(uint => MusicInfo) private musicInfos;
    mapping(uint => address) private musicOwners; // Mapping to track music owners

    constructor(address _musicTicketContract) ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Music/{id}.json") {
        musicTicketContract = MusicTicket(_musicTicketContract);
    }

    function mintMusic(string memory singerName, string memory composer, string memory lyricist, uint releaseDate) public {
        uint id = musicIndex++;
        musicInfos[id] = MusicInfo(id, singerName, composer, lyricist, releaseDate);
        musicOwners[id] = msg.sender;
        _mint(msg.sender, id, 1, "");
    }

    function mintTicket(uint musicId, uint price, uint amount) public {
        require(musicId < musicIndex, "Music does not exist");
        require(musicOwners[musicId] == msg.sender, "Only the music owner can mint tickets");
        musicTicketContract.mintTicket(musicId, price, amount);
    }

    function mintMusicAndTickets(string memory singerName, string memory composer, string memory lyricist, uint releaseDate, uint price, uint amount) public {
        mintMusic(singerName, composer, lyricist, releaseDate); // First, mint the music
        uint musicId = musicIndex - 1; // Get the id of the last minted music
        musicTicketContract.mintTicket(musicId, price, amount); // Then mint tickets for this music
    }

    function buyTickets(uint[] memory ticketIds, uint[] memory amounts) public payable {
        musicTicketContract.buyTickets(ticketIds, amounts);
    }

    function streamMusic(uint ticketId) public {
        musicTicketContract.streamMusic(ticketId);
    }

    function downloadMusic(uint ticketId) public {
        musicTicketContract.downloadMusic(ticketId);
    }

    function getMusicInfo(uint id) public view returns (MusicInfo memory) {
        return musicInfos[id];
    }

    function ownerOf(uint id) public view returns (address) {
        return musicOwners[id]; // Return the music owner
    }

    function getTicketInfo(uint ticketId) public view returns (MusicTicket.TicketInfo memory) {
        return musicTicketContract.getTicketInfo(ticketId);
    }
}
