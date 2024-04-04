/**
 * WARNING: This contract is currently in development and all tests have not yet been completed.
 * Therefore, it is not recommended to use it in production environments.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../extensions/ERC721LimitableMint.sol";

contract AdvancedPublicMintERC721 is
    ERC721,
    ERC721Burnable,
    ERC721LimitableMint,
    Ownable,
    ReentrancyGuard
{
    string private _baseTokenURI;
    string private _tokenURISuffix;
    uint256 public mintAmount;
    uint256 private _nextTokenId;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        _baseTokenURI = uri_;
        _tokenURISuffix = ".json";
        mintAmount = 0.5 ether;
    }

    function safeMint(
        address to_
    ) public payable maxMintCountCheck maxMintCountPerAddressCheck {
        require(to_ != address(0), "Invalid Address Error");
        require(
            msg.value > 0 && msg.value == mintAmount,
            "Invalid Payment Error"
        );
        uint256 tokenId = _nextTokenId++;
        _updateCurrentMintCount(tokenId);
        _updatemintedTokensByAddress();
        _safeMint(to_, tokenId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(
        uint256 tokenId_
    ) public view override returns (string memory) {
        return
            string(abi.encodePacked(super.tokenURI(tokenId_), _tokenURISuffix));
    }

    function setMaxMintCount(uint256 count_) external onlyOwner {
        _setMaxMintCount(count_);
    }

    function setMaxMintCountPerAddress(uint256 count_) external onlyOwner {
        _setMaxMintCountPerAddress(count_);
    }

    function setBaseTokenURI(string calldata uri_) external onlyOwner {
        _baseTokenURI = uri_;
    }

    function setTokenURISuffix(string calldata suffix_) external onlyOwner {
        _tokenURISuffix = suffix_;
    }

    function setMintAmount(uint256 amount_) external onlyOwner {
        mintAmount = amount_;
    }

    function currentMintCount() external onlyOwner {
        _getCurrentMintCount();
    }

    function withdraw() external onlyOwner nonReentrant {
        require(address(this).balance > 0);
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Withdraw Error");
    }
}
