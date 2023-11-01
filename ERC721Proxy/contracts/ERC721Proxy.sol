// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/Proxy.sol)

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/utils/Address.sol";
import "../node_modules/@openzeppelin/contracts/utils/Context.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. We refer to the second contract as the _implementation_ behind the proxy, and it has to
 * be specified by overriding the  {_implementation} function.
 *
 * Additionally, delegation to the implementation can be triggered manually through the {_fallback} function, or to a
 * different contract through the {_delegate} function.
 *
 * The success and return data of the delegated call will be returned back to the caller of the proxy.
 */
/*
 * @zio 
 */

contract ProxyERC721 is Context {

    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    address _contract;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(address _ERC721Address, string memory name_, string memory symbol_) {
        _contract = _ERC721Address;
        _name = name_;
        _symbol = symbol_;
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("__ERC721_init(string, string)", name_, symbol_)
        );
    }

    /**
     * @dev You must use this function first, when you after deploy.
     */
    function setERC721Address (address _ERC721Address) public {
        _contract = _ERC721Address;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
     /*
     *
     * @zio This is not using interface!!
     *
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("supportsInterface(bytes4)", interfaceId)
        );
        require(success);
        return abi.decode(dataReturn, (bool));
    }
    */

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public returns (string memory) {
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("tokenURI(uint256)", tokenId)
        );
        require(success);
        return abi.decode(dataReturn, (string));
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ProxyERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );
        
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("approve(address, uint256)", to, tokenId)
        );
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public {
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("setApprovalForAll(address, bool)", operator, approved)
        );
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("transferFrom(address, address, uint256)", from, to, tokenId)
        );
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("safeTransferFrom(address, address, uint256", from, to, tokenId)
        );
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("safeTransferFrom(address, address, uint256, bytes)", from, to, tokenId, data)
        );
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        (bool success, bytes memory dataReturn) = _contract.delegatecall(
            abi.encodeWithSignature("_safeMint(address, uint256)", to, tokenId)
        );
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     
     /*
     * @zio Declared only the necessary internal functions!! 
     */
    
    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ProxyERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

        /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
}