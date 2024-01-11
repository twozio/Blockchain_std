// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./sub/ERC721Enumerable.sol";

contract Copyright is ERC721Enumerable {

    address private owner;
    mapping(uint256 => string) private _tokenUris;

    mapping(uint => CopyrightInfo) internal copyrightInfoMap;

    event download(address copyrightOwner, uint copyrightId);
    event copyrightMint(address copyrightOwner, uint copyrightId);
    event copyrightBuy(address copyrightOwner, address beforeOwner, uint copyrightId);

    struct CopyrightInfo {
        // uint price;
        string downloadUri;
        uint usableTotalCnt;
        uint useCnt;
        bool sellYn;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function getCopyrightInfo(uint copyrightId) public view returns (CopyrightInfo memory) {
        return copyrightInfoMap[copyrightId];
    }

    function tokenURI(uint256 copyrightId) public view virtual override returns (string memory) {
        _checkExistsToken(copyrightId);
        return _tokenUris[copyrightId];
    }

    // Change copyright available. You can stop or start the sale.
    function modifySellYn(uint copyrightId, bool sellYn) public onlyOwner {
        copyrightInfoMap[copyrightId].sellYn = sellYn;
    }

    function modifyTokenUri(uint copyrightId, string memory tokenUri) public onlyOwner {
        _tokenUris[copyrightId] = tokenUri;
    }

    // Copyright NFT minting.
    function mintCopyright(address to, uint copyrightId, string memory tokenUri, string memory downloadUri, uint usableTotalCnt, bool sellYn) public onlyOwner {
        _safeMint(to, copyrightId);
        // copyrightInfoMap[copyrightId].price = price;
        copyrightInfoMap[copyrightId].downloadUri = downloadUri;
        copyrightInfoMap[copyrightId].usableTotalCnt = usableTotalCnt;
        copyrightInfoMap[copyrightId].useCnt = 0;
        copyrightInfoMap[copyrightId].sellYn = sellYn;
        _tokenUris[copyrightId] = tokenUri;

        emit copyrightMint(to, copyrightId);
    }

    // Download ticket minting.
    function buyCopyrightTicket(
        address to,
        uint copyrightId
    ) public onlyOwner {
        require(copyrightInfoMap[copyrightId].sellYn, "This is an unsold product.");
        
        emit copyrightBuy(to, ownerOf(copyrightId), copyrightId);
        
        safeTransferFrom(ownerOf(copyrightId), to, copyrightId);
    }

    // Use the download ticket.
    function useDownload(address copyrightOwner, uint copyrightId) public onlyOwner {
         _checkExistsToken(copyrightId);
        require(copyrightOwner == ownerOf(copyrightId), "Only the nft owner can call this function");
        require(
            copyrightInfoMap[copyrightId].usableTotalCnt > copyrightInfoMap[copyrightId].useCnt,
            "There are no remaining counts"
        );
        copyrightInfoMap[copyrightId].useCnt++;

        emit download(copyrightOwner, copyrightId);

    }

    function modifyDownloadTokenUri(uint copyrightId, string memory tokenUri) public onlyOwner {
        copyrightInfoMap[copyrightId].downloadUri = tokenUri;
    }

    function modifyDownloadTotalCnt(uint copyrightId, uint totalCnt) public onlyOwner {
        copyrightInfoMap[copyrightId].usableTotalCnt = totalCnt;
    }

    // private function
    function _checkExistsToken(uint256 copyrightId) private view {
        require(_exists(copyrightId), "Token not exists.");
    }
}