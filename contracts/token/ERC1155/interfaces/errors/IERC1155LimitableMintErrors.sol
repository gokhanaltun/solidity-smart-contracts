// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC1155LimitableMintErrors {

    error TokenIsNotMintable(uint256 tokenId);

    error MaxTotalSupplyReached(uint256 tokenId);

    error MintLimitReached(address addr);

    error MaxMintLimitPerAddressExceedsTotalSupply(uint256 expectedMax);

    error MintAmountExceedsTotalSupply();

    error MaxMintLimitCannotBeSmallerThanMaxMintLimitPerAddress(uint256 expectedMin);

    error MintAmountExceedsMaxMintLimitPerAddress();
}