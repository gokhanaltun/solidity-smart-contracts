/**
 * WARNING: This contract is currently in development and all tests have not yet been completed.
 * Therefore, it is not recommended to use it in production environments.
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CoreERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title SimpleOwnerMintERC1155
 * @dev ERC1155 token contract that allows only the owner to mint new tokens.
 */
contract SimpleOwnerMintERC1155 is CoreERC1155, Ownable {
    using Strings for uint256;

    /**
     * @dev Constructor function to initialize the ERC1155 token with the specified name, symbol, and base URI.
     * @param name_ The name of the ERC1155 token.
     * @param symbol_ The symbol of the ERC1155 token.
     * @param uri_ The base URI for token metadata. Example: ipfs://CID/
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) CoreERC1155(name_, symbol_, uri_) Ownable(_msgSender()) {}

    /**
     * @dev Sets the base URI for token metadata.
     * @param newURI_ The new base URI.
     */
    function setURI(string memory newURI_) public onlyOwner {
        _setURI(newURI_);
    }

    /**
     * @dev Mints a new token to the specified account.
     * @param account_ The address to which the new tokens will be minted.
     * @param id_ The ID of the token to mint.
     * @param amount_ The amount of tokens to mint.
     */
    function mint(
        address account_,
        uint256 id_,
        uint256 amount_
    ) external onlyOwner {
        _mint(account_, id_, amount_, "");
    }

    /**
     * @dev Returns the URI for a given token ID.
     * @param tokenId_ The ID of the token.
     * @return The URI for the token metadata.
     */
    function uri(
        uint256 tokenId_
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(super.uri(0), tokenId_.toString(), ".json")
            );
    }
}
