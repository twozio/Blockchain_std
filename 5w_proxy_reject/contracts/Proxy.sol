// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Download.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Proxy is ERC721Enumerable {
    Download private download;
    address private owner;
    mapping(uint256 => string) private _tokenUris;

    mapping(uint => BaseCopyrightInfo) internal baseCopyrightInfoMap;

    struct BaseCopyrightInfo {
        uint buyCnt;
        uint mintCnt;
        uint downloadCnt;
        bool sellYn;
    }

    address public CopyrightLogic;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function setImplementation(address _newCopyright) public onlyOwner {
        CopyrightLogic = _newCopyright;
    }

    function getImplementation() public view returns (address) {
        return CopyrightLogic;
    }

    function getCopyrightInfo(uint copyrightId) public view returns (BaseCopyrightInfo memory) {
        return baseCopyrightInfoMap[copyrightId];
    }

    function getDownloadAddress() public view returns (address) {
        return address(download);
    }

    fallback() external {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(
                gas(),
                sload(CopyrightLogic.slot),
                ptr,
                calldatasize(),
                0,
                0
            )

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
            revert(ptr, size)
            }
            default {
            return(ptr, size)
            }
        }
    }
}