// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev ERC721LimitableMintErrors interface defines the types of errors that can occur during token minting operations.
 */
interface ERC721LimitableMintErrors {
    /**
     * @dev Error triggered when the mint limit per address is reached.
     * @param addr The address for which the mint limit is reached.
     */
    error AddressMintLimitReached(address addr);

    /**
     * @dev Error triggered when the maximum total supply limit is reached.
     * @param addr The address causing the maximum total supply limit to be reached.
     */
    error MaxTotalSupplyReached(address addr);

    /**
     * @dev Error triggered when the maximum mint limit per address exceeds the total supply limit.
     * @param expectedMax The expected maximum mint limit per address.
     * @param current The current total supply.
     */
    error MaxMintLimitPerAddressExceedsTotalSupply(uint256 expectedMax, uint256 current);
}
