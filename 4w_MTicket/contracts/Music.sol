// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Music is ERC1155 {
    // Define the structure of a Music Info
    struct MusicInfo {
        uint id;
        address owner;
        string name;
        // Additional attributes
    }

    uint private musicIndex = 1;
    mapping(uint => MusicInfo) private MusicInfos;

    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/Music/{id}.json") {}

    // Event to notify when a new music item is minted
    event MusicMinted(uint indexed id, address indexed owner, string name);

    // Function to mint a new music item
    function mintMusic(string memory name) public returns (uint) {
        uint id = musicIndex;
        MusicInfos[id] = MusicInfo({
            id: id,
            owner: msg.sender,
            name: name
            // Additional attributes
        });
        _mint(msg.sender, id, 1, "");
        musicIndex++;
        emit MusicMinted(id, msg.sender, name);
        return id;
    }

    // Additional functions to manage or verify ownership of music items
}
