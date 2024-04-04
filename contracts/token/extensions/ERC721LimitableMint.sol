// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract ERC721LimitableMint is Context {
    uint256 private _currentMintCount;
    uint256 private _maxMintCount;
    uint256 private _maxMintCountPerAddress;
    mapping(address => uint256) private _mintedTokensByAddress;

    modifier maxMintCountPerAddressCheck() {
        require(
            _mintedTokensByAddress[_msgSender()] < _maxMintCountPerAddress,
            "Max Mint Count Per Address Error"
        );
        _;
    }

    modifier maxMintCountCheck() {
        require(_currentMintCount < _maxMintCount, "Sold Out Error");
        _;
    }

    function _updateCurrentMintCount(uint256 count_) internal virtual {
        _currentMintCount = count_;
    }

    function _updatemintedTokensByAddress() internal virtual {
        _mintedTokensByAddress[_msgSender()]++;
    }

    function _setMaxMintCount(uint256 count_) internal {
        _maxMintCount = count_;
    }

    function _setMaxMintCountPerAddress(uint256 count_) internal {
        _maxMintCountPerAddress = count_;
    }

    function getMaxMintCount() public virtual returns(uint256) {
        return _maxMintCount;
    }

    function getMaxMintCountPerAddress() public virtual returns(uint256) {
        return _maxMintCountPerAddress;
    }

    function _getCurrentMintCount() internal virtual returns(uint256) {
        return _currentMintCount;
    }
}
