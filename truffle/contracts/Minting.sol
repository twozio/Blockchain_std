// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

contract Minting is ERC721 {
    //ERC 721 생성자 함수 실행 ERC721(_name, _symbol)
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

    function _minting(uint _tokenId) public {
        _mint(msg.sender, _tokenId);
        // _tokenId : 토큰의 고유한 키값, msg.sender : 토큰 받을 계정
    }

    function tokenURI(uint _tokenId) public override pure returns (string memory) {
        return 'https://gateway.pinata.cloud/ipfs/QmPwjnvWYN4etA5eW4yAbWCTy2ukEC1Jj5417VLGyH5XpU/1/1.json';
    }
    // NFT에 대한 정보를 JSON 파일에 보관
}

