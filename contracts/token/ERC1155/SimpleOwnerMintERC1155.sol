// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CoreERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

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

    function setURI(string memory newURI_) public onlyOwner {
        _setURI(newURI_);
    }

    function mint(
        address account_,
        uint256 id_,
        uint256 amount_
    ) external onlyOwner {
        _mint(account_, id_, amount_, "");
    }

    function uri(
        uint256 tokenId_
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(super.uri(0), tokenId_.toString(), ".json")
            );
    }
}
