// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract E1155test is ERC1155 {
    constructor() ERC1155("Test") {

    }
}