/**
 * WARNING: This contract is currently in development and all tests have not yet been completed.
 * Therefore, it is not recommended to use it in production environments.
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./extensions/ERC1155LimitableMint.sol";
import "../../utils/PaymentCheck.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title AdvancedPublicMintERC1155
 * @dev This contract extends ERC1155LimitableMint, PaymentCheck, and Ownable contracts.
 * It enables advanced public minting of ERC-1155 tokens with features like limiting the minting per token and per address.
 */
contract AdvancedPublicMintERC1155 is
    ERC1155LimitableMint,
    PaymentCheck,
    Ownable
{
    using Strings for uint256;

    // The amount required for minting each token.
    uint256 public mintAmount;

    /**
     * @dev Constructor to initialize the contract with name, symbol, and base URI.
     * @param name_ The name of the token collection.
     * @param symbol_ The symbol of the token collection.
     * @param uri_ The base URI for token metadata. Example: ipfs://CID/
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) CoreERC1155(name_, symbol_, uri_) Ownable(_msgSender()) {
        mintAmount = 0.5 ether;
    }

    /**
     * @dev Overrides the URI method to append token ID to the base URI.
     * @param tokenId_ The ID of the token.
     * @return The URI of the token metadata.
     */
    function uri(
        uint256 tokenId_
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(super.uri(0), tokenId_.toString(), ".json")
            );
    }

    /**
     * @dev Sets the base URI for all token metadata.
     * @param newURI_ The new base URI. Example: ipfs://CID/
     */
    function setURI(string memory newURI_) public onlyOwner {
        _setURI(newURI_);
    }

    /**
     * @dev Allows minting of tokens by paying the required amount.
     * @param account_ The address to which tokens will be minted.
     * @param tokenId_ The ID of the token to be minted.
     * @param amount_ The amount of tokens to be minted.
     */
    function mint(
        address account_,
        uint256 tokenId_,
        uint256 amount_
    ) external payable {
        /**
            @dev see {PayableCheck}
         */
        _paymentMustBeGreaterThanZero();
        _paymentMustBeEqualToExpectedPaymentAmount(mintAmount);

        /**
            @dev see {ERC1155LimitableMint}
         */
        _checkMaxMintCountPerTokenBeforeMint(tokenId_, amount_);
        _checkMaxMintCountPerAddressBeforeMint(account_, tokenId_, amount_);
        _updateCurrentCounts(tokenId_, amount_);
        
        // Calls ERC1155 mint function to mint tokens.
        _mint(account_, tokenId_, amount_, "");
    }

    /**
     * @dev see {ERC1155LimitableMint}
     */
    function setMaxMintCountPerToken(
        uint256 tokenId_,
        uint256 limit_
    ) external onlyOwner {
        _setMaxMintCountPerToken(tokenId_, limit_);
    }

    /**
     * @dev see {ERC1155LimitableMint}
     */
    function setMaxMintCountPerAddress(
        uint256 tokenId_,
        uint256 limit_
    ) external onlyOwner {
        _setMaxMintCountPerAddress(tokenId_, limit_);
    }

    /**
     * @dev Sets the amount required for minting each token.
     * @param amount_ The new mint amount.
     */
    function setMintAmount(uint256 amount_) external onlyOwner {
        mintAmount = amount_;
    }


    /**
     * @dev Allows the owner to withdraw the contract balance.
     */
    function withdraw() external onlyOwner {
        _balanceMustNotBeZero(address(this));
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Withdraw Error");
    }
}
