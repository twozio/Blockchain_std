// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProxyCopyright {
    address public Copyright;

    constructor(address _newCopyright) {
        Copyright = _newCopyright;
    }

    function setImplementation(address _newCopyright) public {
        // Add proper access controls in production
        Copyright = _newCopyright;
    }

    fallback() external payable {
        address copyrightAddr = Copyright;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), copyrightAddr, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    receive() external payable {
        // React to receiving ether
    }
}
