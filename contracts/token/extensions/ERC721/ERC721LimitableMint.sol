// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev This abstract contract provides functionality for limiting the minting of ERC721 tokens.
 */
abstract contract ERC721LimitableMint is Context {
    uint256 private _currentMintCount; // The current count of minted tokens
    uint256 private _maxMintCount; // The maximum allowed mint count for this contract
    uint256 private _maxMintCountPerAddress; // The maximum allowed mint count per address
    mapping(address => uint256) private _mintedTokensByAddress; // Mapping to track minted tokens by address

    /**
     * @dev Modifier to check if the maximum mint count per address has been reached.
     */
    modifier maxMintCountPerAddressCheck() {
        require(
            _mintedTokensByAddress[_msgSender()] < _maxMintCountPerAddress,
            "Max Mint Count Per Address Error"
        );
        _;
    }

    /**
     * @dev Modifier to check if the maximum mint count for this contract has been reached.
     */
    modifier maxMintCountCheck() {
        require(_currentMintCount < _maxMintCount, "Sold Out Error");
        _;
    }

    /**
     * @dev Internal function to increment the current mint count.
     */
    function _incrementCurrentMintCount() internal virtual {
        _currentMintCount++;
    }

    /**
     * @dev Internal function to update minted tokens count by address.
     */
    function _updatemintedTokensByAddress() internal virtual {
        _mintedTokensByAddress[_msgSender()]++;
    }

    /**
     * @dev Internal function to set the maximum mint count for this contract.
     * @param count_ The maximum mint count to set.
     */
    function _setMaxMintCount(uint256 count_) internal {
        _maxMintCount = count_;
    }

    /**
     * @dev Internal function to set the maximum mint count per address for this contract.
     * @param count_ The maximum mint count per address to set.
     */
    function _setMaxMintCountPerAddress(uint256 count_) internal {
        _maxMintCountPerAddress = count_;
    }

    /**
     * @dev Public function to get the maximum mint count for this contract.
     * @return return the maximum mint count
     */
    function _getMaxMintCount() internal view returns (uint256) {
        return _maxMintCount;
    }

    /**
     * @dev Public function to get the maximum mint count per address for this contract.
     */
    function _getMaxMintCountPerAddress() internal view returns (uint256) {
        return _maxMintCountPerAddress;
    }

    /**
     * @dev Internal function to get the current mint count for this contract.
     */
    function _getCurrentMintCount() internal view returns (uint256) {
        return _currentMintCount;
    }
}
