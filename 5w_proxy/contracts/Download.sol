// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Copyright.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Download is ERC721Enumerable {
    Copyright private Cp;
    mapping(uint256 => string) private _tokenUris;

    mapping(uint => DownloadInfo) public downloadInfo;
    mapping(uint => mapping(address => bool)) private existsDownloadInfoMap;

    struct DownloadInfo {
        uint copyrightId;
        uint usableTotalCnt;
        uint useCnt;
    }

    // Only Copyright.sol can call some functions.
    modifier onlyCopyrightContract() {
        require(msg.sender == address(Cp), "Only the Music contract can call this function!");
        _;
    }

    /**
     * @dev You must deploy the copyright contract first.
     */
    constructor(address copyrightAddress) ERC721("name","symbol") {
        Cp = Copyright(copyrightAddress);
    }

    function modifyTokenUri(uint downloadId, string memory tokenUri) public {
        _checkExistsToken(downloadId);
        _tokenUris[downloadId] = tokenUri;
    }

    function modifyDownloadTotalCnt(uint downloadId, uint totalCnt) public {
        _checkExistsToken(downloadId);
        require(downloadInfo[downloadId].useCnt <= totalCnt, "useCnt must be less than or equal to totalCnt");
        downloadInfo[downloadId].usableTotalCnt = totalCnt;
    }

    function tokenURI(uint256 downloadId) public view virtual override returns (string memory) {
        _checkExistsToken(downloadId);
        return _tokenUris[downloadId];
    }

    // Get the information that copyright's ticket.
    function getDownloadInfo(uint downloadId) public view returns (DownloadInfo memory) {
        _checkExistsToken(downloadId);
        return downloadInfo[downloadId];
    }

    // Transfer ticket to customer. This function can only be called by a copyright contract.
    function transferTicket(address from, address to, uint downloadId) public onlyCopyrightContract {
        safeTransferFrom(from, to, downloadId);
    }

    // Download ticket minting. This function can only be called by a copyright contract.
    function buyDownload(
        address to,
        uint copyrightId,
        uint downloadId,
        uint count,
        string memory tokenUri
    ) public onlyCopyrightContract returns (bool) {
        downloadInfo[downloadId].copyrightId = copyrightId;
        if (_exists(downloadId)) {
            downloadInfo[downloadId].usableTotalCnt += count;
            return false;
        } else {
            require(existsDownloadInfoMap[copyrightId][to], "This download already exists");
            _mint(to, downloadId);
            _tokenUris[downloadId] = tokenUri;
            existsDownloadInfoMap[copyrightId][to] = true;
            return true;
        }
    }

    // Ticket use.
    function useDownload(address downloadOwner, uint downloadId) public {
        _checkExistsToken(downloadId);
        require(downloadOwner == ownerOf(downloadId), "Only the nft owner can call this function");
        require(
            downloadInfo[downloadId].usableTotalCnt > downloadInfo[downloadId].useCnt,
            "There are no remaining counts"
        );
        downloadInfo[downloadId].useCnt++;
    }

    // private function
    function _checkExistsToken(uint256 tokenId) private view {
        require(_exists(tokenId), "Token not exists.");
    }
}