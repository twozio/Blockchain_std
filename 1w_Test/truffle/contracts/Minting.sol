// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';

import '../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract Minting is ERC721 {
    //ERC 721 생성자 함수 실행 ERC721(_name, _symbol)
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {

    }

    function _minting(uint _tokenId) public {
        _mint(msg.sender, _tokenId);
        // _tokenId : 토큰의 고유한 키값, msg.sender : 토큰 받을 계정
    }

    function tokenURI(uint _tokenId) public override pure returns (string memory) {
        return 'ipfs://bafkreiaukgn6brlzkwiuedz4k23va22gwmydwx2nhvlompnryqo66mego4';
    }
    // NFT에 대한 정보를 JSON 파일에 보관
    function burn(uint _tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: caller is not token owner or approved");
        _burn(_tokenId);
    }

    function burningsea(uint _tokenId) public {
        _transfer(ownerOf(_tokenId), 0x000000000000000000000000000000000000dEaD, _tokenId);
    }

    function _Transfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _safeTransfer(from, to, tokenId, data);
    }

}


