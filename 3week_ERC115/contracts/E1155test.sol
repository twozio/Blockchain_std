// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract E1155test is ERC1155 {
    constructor() ERC1155("https://dev-internship.s3.ap-northeast-2.amazonaws.com/erc1155/{id}.json") {}

    function mint_all() public {
        for(uint i = 1; i < 8; i++){
            _mint(msg.sender, i, 10**i, "");
        }
    }

    function burn_all() public {
        for(uint i = 1; i < 8; i++){
            _burn(msg.sender, i, 10**i);
        }
    }

    function transfer(address to) public {
        _safeTransferFrom(msg.sender, to, 1, 1,"");
    }
}
