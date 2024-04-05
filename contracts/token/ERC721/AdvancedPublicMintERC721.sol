/**
 * WARNING: This contract is currently in development and all tests have not yet been completed.
 * Therefore, it is not recommended to use it in production environments.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../extensions/ERC721/ERC721LimitableMint.sol";
import "../../utils/PayableCheck.sol";

contract AdvancedPublicMintERC721 is
    ERC721,
    ERC721LimitableMint,
    PayableCheck,
    Ownable,
    ReentrancyGuard
{
    string private _baseTokenURI;
    uint256 public mintAmount;

    /**
     * @dev Constructor function to initialize the ERC721 token with the specified name, symbol, and base URI.
     * @param name_ The name of the ERC721 token.
     * @param symbol_ The symbol of the ERC721 token.
     * @param uri_ The base URI for token metadata. Example: ipfs://CID/
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        _baseTokenURI = uri_;
        mintAmount = 0.5 ether;
    }

    /**
     * @dev This function safely mints an ERC721 token for a specific address and checks the collected payment amount.
     * @param to_ The address to mint the token for.
     */
    function safeMint(
        address to_
    ) public payable maxMintCountCheck maxMintCountPerAddressCheck {
        _paymentMustBeEqualToExpectedPaymentAmount(mintAmount);
        _incrementCurrentMintCount();
        _updatemintedTokensByAddress();
        _safeMint(to_, _getCurrentMintCount());
    }

    /**
     * @dev This function returns the base URI.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev This function returns the full URI for a specific token.
     * @param tokenId_ The ID of the token.
     */
    function tokenURI(
        uint256 tokenId_
    ) public view override returns (string memory) {
        return
            string(abi.encodePacked(super.tokenURI(tokenId_), ".json"));
    }

    /**
     * @dev see {ERC721LimitableMint.sol}
     * @param count_ The maximum mint count to set.
     */
    function setMaxMintCount(uint256 count_) external onlyOwner {
        _setMaxMintCount(count_);
    }

    /**
     * @dev see {ERC721LimitableMint.sol}
     * @param count_ The maximum mint count per address to set.
     */
    function setMaxMintCountPerAddress(uint256 count_) external onlyOwner {
        _setMaxMintCountPerAddress(count_);
    }

    /**
     * @dev Sets the base token URI for this contract.
     * @param uri_ The base token URI to set.
     */
    function setBaseTokenURI(string calldata uri_) external onlyOwner {
        _baseTokenURI = uri_;
    }

    /**
     * @dev Sets the amount per mint for this contract.
     * @param amount_ The mint amount to set.
     */
    function setMintAmount(uint256 amount_) external onlyOwner {
        mintAmount = amount_;
    }

    /**
     * @dev see {ERC721LimitableMint.sol}
     */
    function currentMintCount() external view onlyOwner returns (uint256) {
        return _getCurrentMintCount();
    }

    /**
     * @dev see {ERC721LimitableMint.sol}
     */
    function maxMintCount() external view onlyOwner returns (uint256) {
        return _getMaxMintCount();
    }

    /**
     * @dev see {ERC721LimitableMint.sol}
     */
    function maxMintCountPerAddress() external view onlyOwner returns (uint256) {
        return _getMaxMintCountPerAddress();
    }

    /**
     * @dev Withdraws the contract balance to the owner's address.
     */
    function withdraw() external onlyOwner nonReentrant {
        _balanceMustNotBeInsufficient(address(this));
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw Error");
    }
}
