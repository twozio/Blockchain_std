// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./Download.sol";

contract Copyright is ERC721Upgradeable {
    Download private download;
    address private owner;
    mapping(uint256 => string) private _tokenUris;

    mapping(uint => UsageInfo) internal copyrightInfoMap;

    struct UsageInfo {
        uint buyCnt;
        uint mintCnt;
        uint downloadCnt;
        bool sellYn;
    }

    function initialize() public initializer {
        owner = msg.sender;
        __ERC721_init("name","symbol");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier onlyNftOwner(uint copyrightId) {
        require(msg.sender == ownerOf(copyrightId), "Only the nft owner can call this function");
        _;
    }

    function getUsageInfo(uint copyrightId) public view returns (UsageInfo memory) {
        return copyrightInfoMap[copyrightId];
    }

    function tokenURI(uint256 copyrightId) public view virtual override returns (string memory) {
        _checkExistsToken(copyrightId);
        return _tokenUris[copyrightId];
    }

    // Change copyright available. You can stop or start the sale.
    function modifySellYn(uint copyrightId, bool sellYn) public onlyNftOwner(copyrightId) {
        copyrightInfoMap[copyrightId].sellYn = sellYn;
    }

    function modifyTokenUri(uint copyrightId, string memory tokenUri) public onlyNftOwner(copyrightId) {
        _tokenUris[copyrightId] = tokenUri;
    }

    /**
     * @dev After deploy, you need to call this function and set the DownloadTicket.sol address.
     */
    function setDtAddress(address downloadContractAddress) public {
        download = Download(downloadContractAddress);
    }

    // Copyright NFT minting.
    function mintCopyright(uint copyrightId, string memory tokenUri, bool sellYn) public {
        _safeMint(msg.sender, copyrightId);
        copyrightInfoMap[copyrightId].sellYn = sellYn;
        _tokenUris[copyrightId] = tokenUri;
    }

    // Download ticket minting.
    function buyDownloadTicket(uint copyrightId, uint counter, uint price, string memory tokenUri) public {
        require(msg.sender == ownerOf(copyrightId), "Only Copyright owner can mint the tickets!");

        bool isMint = download.buyDownload(msg.sender, copyrightId, counter, price, tokenUri);
        if (isMint) {
            copyrightInfoMap[copyrightId].mintCnt++;
        }
        copyrightInfoMap[copyrightId].buyCnt++;
    }

    // Use the download ticket.
    function useDownload(uint copyrightId) public {
        download.useDownload(msg.sender, copyrightId);
        copyrightInfoMap[copyrightId].downloadCnt++;
    }

    function modifyDownloadTokenUri(uint downloadId, string memory tokenUri) public {
        require(msg.sender == ownerOf(download.getDownloadInfo(downloadId).copyrightId));
        download.modifyTokenUri(downloadId, tokenUri);
    }

    function modifyDownloadTotalCnt(uint downloadId, uint totalCnt) public {
        require(msg.sender == ownerOf(download.getDownloadInfo(downloadId).copyrightId));
        download.modifyDownloadTotalCnt(downloadId, totalCnt);
    }

    // private function
    function _checkExistsToken(uint256 tokenId) private view {
        require(_exists(tokenId), "Token not exists.");
    }
}