/**
 * WARNING: This contract is currently in development and all tests have not yet been completed.
 * Therefore, it is not recommended to use it in production environments.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./extensions/ERC721LimitableMint.sol";
import "../../utils/PaymentCheck.sol";

/**
 * @dev The contract starts minting NFTs with ID = 1. You should adjust your NFT metadata files accordingly.
 */
contract AdvancedPublicMintERC721 is
    ERC721,
    ERC721LimitableMint,
    PaymentCheck,
    Ownable
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
        _updateMintedTokensByAddress();
        _safeMint(to_, getCurrentMintCount());
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
     * @param amount_ The mint amount to set. format: wei
     */
    function setMintAmount(uint256 amount_) external onlyOwner {
        mintAmount = amount_;
    }

    /**
     * @dev Withdraws the contract balance to the owner's address.
     */
    function withdraw() external onlyOwner {
        _balanceMustNotBeZero(address(this));
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdraw Error");
    }
}
