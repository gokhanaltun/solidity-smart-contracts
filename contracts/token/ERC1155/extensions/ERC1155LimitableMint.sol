// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../CoreERC1155.sol";
import "../interfaces/errors/IERC1155LimitableMintErrors.sol";

/**
 * @dev ERC1155LimitableMint contract implements ERC-1155 standards and enables tokens to be minted in a limited amount.
 * It inherits from the CoreERC1155 contract and implements the IERC1155LimitableMintErrors error interface.
 */
abstract contract ERC1155LimitableMint is
    CoreERC1155,
    IERC1155LimitableMintErrors
{
    // Mapping to store the maximum mint count per token.
    mapping(uint256 => uint256) private _maxMintCountPerToken;
    // Mapping to store the maximum mint count per address for a specific token.
    mapping(uint256 => uint256) private _maxMintCountPerAddress;
    // Mapping to store the current mint counts for each token.
    mapping(uint256 => uint256) private _currentMintCounts;

    /**
     * @dev Checks the maximum mint count per token before minting.
     * @param tokenId_ The ID of the token to be minted.
     * @param amount_ The amount of tokens to be minted.
     */
    function _checkMaxMintCountPerTokenBeforeMint(
        uint256 tokenId_,
        uint256 amount_
    ) internal view {
        uint256 currentCountForToken = _currentMintCounts[tokenId_];
        uint256 maxMintCountForToken = _maxMintCountPerToken[tokenId_];

        _checkMintableStatus(tokenId_);

        if (currentCountForToken == maxMintCountForToken) {
            revert MaxTotalSupplyReached(tokenId_);
        }

        uint256 expectedCountAfterMint = currentCountForToken + amount_;

        if (expectedCountAfterMint > maxMintCountForToken) {
            revert MintAmountExceedsTotalSupply();
        }
    }

    /**
     * @dev Checks the maximum mint count per address before minting.
     * @param account_ The address for which the token is to be minted.
     * @param tokenId_ The ID of the token to be minted.
     * @param amount_ The amount of tokens to be minted.
     */
    function _checkMaxMintCountPerAddressBeforeMint(
        address account_,
        uint256 tokenId_,
        uint256 amount_
    ) internal view {
        uint256 addressBalanceForToken = balanceOf(account_, tokenId_);
        uint256 maxMintCountForAddress = _maxMintCountPerAddress[tokenId_];

        _checkMintableStatus(tokenId_);

        if (addressBalanceForToken == maxMintCountForAddress) {
            revert MintLimitReached(account_);
        }

        uint256 expectedCountAfterMint = addressBalanceForToken + amount_;

        if (expectedCountAfterMint > maxMintCountForAddress) {
            revert MintAmountExceedsMaxMintLimitPerAddress();
        }
    }

    /**
     * @dev Updates the current mint counts.
     * @param tokenId_ The ID of the token that has been minted.
     * @param amount_ The amount of tokens that has been minted.
     */
    function _updateCurrentCounts(uint256 tokenId_, uint256 amount_) internal {
        _currentMintCounts[tokenId_] += amount_;
    }

    /**
     * @dev Checks if a token is mintable.
     * @param tokenId_ The ID of the token to be checked.
     */
    function _checkMintableStatus(uint256 tokenId_) private view {
        uint256 maxMintCountForToken = _maxMintCountPerToken[tokenId_];

        if (maxMintCountForToken == 0) {
            revert TokenIsNotMintable(tokenId_);
        }
    }

    /**
     * @dev Sets the maximum mint count per token.
     * @param tokenId_ The ID of the token for which the maximum mint count is to be set.
     * @param limit_ The maximum mint count.
     */
    function _setMaxMintCountPerToken(
        uint256 tokenId_,
        uint256 limit_
    ) internal {
        uint256 maxTokenMintLimitPerAddress = _maxMintCountPerAddress[tokenId_];
        if (limit_ < maxTokenMintLimitPerAddress) {
            revert MaxMintLimitCannotBeSmallerThanMaxMintLimitPerAddress(
                maxTokenMintLimitPerAddress
            );
        }
        _maxMintCountPerToken[tokenId_] = limit_;
    }

    /**
     * @dev Sets the maximum mint count per address for a specific token.
     * @param tokenId_ The ID of the token for which the maximum mint count per address is to be set.
     * @param limit_ The maximum mint count per address.
     */
    function _setMaxMintCountPerAddress(
        uint256 tokenId_,
        uint256 limit_
    ) internal {
        uint256 maxTokenMintLimit = _maxMintCountPerToken[tokenId_];
        if (limit_ > maxTokenMintLimit) {
            revert MaxMintLimitPerAddressExceedsTotalSupply(maxTokenMintLimit);
        }
        _maxMintCountPerAddress[tokenId_] = limit_;
    }
}
