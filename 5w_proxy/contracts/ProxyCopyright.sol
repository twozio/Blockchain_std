// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyCopyright {
    address public Copyright;
    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor(address _newCopyright) {
        Copyright = _newCopyright;
        owner = msg.sender;
    }

    function setImplementation(address _newCopyright) public onlyOwner {
        Copyright = _newCopyright;
    }

    fallback() external payable {
        address impl = Copyright;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}