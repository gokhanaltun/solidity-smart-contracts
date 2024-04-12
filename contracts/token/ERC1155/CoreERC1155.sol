// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/**
 * @title CoreERC1155
 * @dev Core ERC1155 contract providing basic functionality for an ERC1155 token.
 */
abstract contract CoreERC1155 is ERC1155 {
    string private _name;
    string private _symbol;

    /**
     * @dev Constructor function to initialize the CoreERC1155 contract with the specified name, symbol, and URI.
     * @param name_ The name of the ERC1155 token.
     * @param symbol_ The symbol of the ERC1155 token.
     * @param uri_ The base URI for token metadata. Example: ipfs://CID/
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) ERC1155(uri_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the ERC1155 token.
     * @return The name of the ERC1155 token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the ERC1155 token.
     * @return The symbol of the ERC1155 token.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
}