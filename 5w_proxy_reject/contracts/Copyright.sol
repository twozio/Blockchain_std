// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Download.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Copyright is ERC721Upgradeable {
    Download private download;
    address private owner;
    mapping(uint256 => string) private _tokenUris;

    mapping(uint => CopyrightInfo) internal copyrightInfoMap;

    struct CopyrightInfo {
        uint buyCnt;
        uint mintCnt;
        uint downloadCnt;
        bool sellYn;
    }

    function initialize(string memory name, string memory symbol) public initializer {
        owner = _msgSender();
        __ERC721_init(name, symbol);
    }

    modifier onlyOwner() {
        require(_msgSender() == owner, "Only the contract owner can call this function");
        _;
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

    /**
     * @dev After deploy, you need to call this function and set the DownloadTicket.sol address.
     */
    function setDownloadAddress(address downloadContractAddress) public onlyOwner {
        require(address(download) == address(0), "There is already a registered download contract.");
        download = Download(downloadContractAddress);
    }

    // Copyright NFT minting.
    function mintCopyright(address to, uint copyrightId, string memory tokenUri, bool sellYn) public onlyOwner {
        _safeMint(to, copyrightId);
        copyrightInfoMap[copyrightId].sellYn = sellYn;
        _tokenUris[copyrightId] = tokenUri;
    }

    // Download ticket minting.
    function buyDownloadTicket(
        address to,
        uint copyrightId,
        uint downloadId,
        uint count,
        string memory tokenUri
    ) public onlyOwner {
        require(copyrightInfoMap[copyrightId].sellYn, "This is an unsold product.");
        bool isMint = download.buyDownload(to, copyrightId, downloadId, count, tokenUri);
        if (isMint) {
            copyrightInfoMap[copyrightId].mintCnt++;
        }
        copyrightInfoMap[copyrightId].buyCnt++;
    }

    // Use the download ticket.
    function useDownload(address downloadOwner, uint downloadId) public onlyOwner {
        download.useDownload(downloadOwner, downloadId);
        copyrightInfoMap[download.getDownloadInfo(downloadId).copyrightId].downloadCnt++;
    }

    function modifyDownloadTokenUri(uint downloadId, string memory tokenUri) public onlyOwner {
        download.modifyTokenUri(downloadId, tokenUri);
    }

    function modifyDownloadTotalCnt(uint downloadId, uint totalCnt) public onlyOwner {
        download.modifyDownloadTotalCnt(downloadId, totalCnt);
    }

    // private function
    function _checkExistsToken(uint256 copyrightId) private view {
        require(_exists(copyrightId), "Token not exists.");
    }
}