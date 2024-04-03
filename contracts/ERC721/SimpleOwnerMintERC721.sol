/**
    !Disclaimer!
    
    This contract is prepared for example purposes only.
    Please evaluate these codes according to your own needs and security requirements before using them in production environments.
    Carefully review these codes before use and assess your own risk.
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title OwnerMintERC721
 * @dev A contract to facilitate owner minting of ERC721 tokens.
 */
contract SimpleOwnerMintERC721 is ERC721, Ownable {

    /**
     * @dev Constructor to initialize the ERC721 token with a name and symbol.
     * @param name_ The name of the token. Example: "MyNFT"
     * @param symbol_ The symbol of the token. Example: "MN"
     */
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {}

    /**
     * @dev Safely mints a new token and assigns it to an address.
     * Only the owner of the contract can call this function.
     * @param to_ The address that will receive the minted token.
     * @param tokenId_ The unique ID for the newly minted token.
     */
    function safeMint(address to_, uint256 tokenId_) public onlyOwner {
        _safeMint(to_, tokenId_);
    }

    /**
     * @dev Internal function to define the base URI for all token IDs.
     * @return The base URI for token IDs.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "YOUR_BASE_URI_HERE"; // Example: "ipfs://CID/"
    }

    /**
     * @dev Retrieves the URI for a specific token.
     * @param tokenId_ The ID of the token to retrieve the URI for.
     * @return The URI for the specified token.
     */
    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        return string(abi.encodePacked(super.tokenURI(tokenId_), ".json"));
    }
}
