// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Context.sol";
import "../interfaces/errors/ERC721LimitableMintErrors.sol";

/**
 * @dev This abstract contract provides functionality for limiting the minting of ERC721 tokens.
 */
abstract contract ERC721LimitableMint is ERC721LimitableMintErrors, Context {
    uint256 private _currentMintCount; // The current count of minted tokens
    uint256 private _maxMintCount; // The maximum allowed mint count for this contract
    uint256 private _maxMintCountPerAddress; // The maximum allowed mint count per address
    mapping(address => uint256) private _mintedTokensByAddress; // Mapping to track minted tokens by address

    /**
     * @dev Modifier to check if the maximum mint count per address has been reached.
     */
    modifier maxMintCountPerAddressCheck() {
        if (_mintedTokensByAddress[_msgSender()] >= _maxMintCountPerAddress) {
            revert AddressMintLimitReached(_msgSender());
        }
        _;
    }

    /**
     * @dev Modifier to check if the maximum mint count for this contract has been reached.
     */
    modifier maxMintCountCheck() {
        if (_currentMintCount >= _maxMintCount) {
            revert MaxTotalSupplyReached(_msgSender());
        }
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
    function _updateMintedTokensByAddress() internal virtual {
        _mintedTokensByAddress[_msgSender()]++;
    }

    /**
     * @dev Internal function to set the maximum mint count for this contract.
     * @param count_ The maximum mint count to set.
     */
    function _setMaxMintCount(uint256 count_) internal virtual {
        _maxMintCount = count_;
    }

    /**
     * @dev Internal function to set the maximum mint count per address for this contract.
     * @param count_ The maximum mint count per address to set.
     */
    function _setMaxMintCountPerAddress(uint256 count_) internal virtual {
        if (count_ > _maxMintCount){
            revert MaxMintLimitPerAddressExceedsTotalSupply(_maxMintCount, count_);
        }
        _maxMintCountPerAddress = count_;
    }

    /**
     * @dev Public function to get the maximum mint count for this contract.
     * @return return the maximum mint count
     */
    function getMaxMintCount() public view virtual returns (uint256) {
        return _maxMintCount;
    }

    /**
     * @dev Public function to get the maximum mint count per address for this contract.
     */
    function getMaxMintCountPerAddress() public view virtual returns (uint256) {
        return _maxMintCountPerAddress;
    }

    /**
     * @dev Internal function to get the current mint count for this contract.
     */
    function getCurrentMintCount() public view virtual returns (uint256) {
        return _currentMintCount;
    }
}
