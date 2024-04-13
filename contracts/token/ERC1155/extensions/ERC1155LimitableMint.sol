// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../CoreERC1155.sol";
import "../interfaces/errors/IERC1155LimitableMintErrors.sol";

abstract contract ERC1155LimitableMint is CoreERC1155, IERC1155LimitableMintErrors{

    mapping(uint256 => uint256) private _maxMintCountPerToken;
    mapping(uint256 => uint256) private _maxMintCountPerAddress; 
    mapping(uint256 => uint256) private _currentMintCounts;

    function _checkMaxMintCountPerTokenBeforeMint(uint256 tokenId_, uint256 amount_) internal view {
        uint256 currentCountForToken = _currentMintCounts[tokenId_];
        uint256 maxMintCountForToken = _maxMintCountPerToken[tokenId_];
        
        _checkMintableStatus(tokenId_);

        if (currentCountForToken == maxMintCountForToken){
            revert MaxTotalSupplyReached(tokenId_);
        }

        uint256 expectedCountAfterMint = currentCountForToken + amount_;

        if (expectedCountAfterMint > maxMintCountForToken){
            revert MintAmountExceedsTotalSupply();
        } 
    }

     function _checkMaxMintCountPerAddressBeforeMint(address account_, uint256 tokenId_, uint256 amount_) internal view {
        uint256 addressBalanceForToken = balanceOf(account_, tokenId_);
        uint256 maxMintCountForAddress = _maxMintCountPerAddress[tokenId_];

        _checkMintableStatus(tokenId_);

        if (addressBalanceForToken == maxMintCountForAddress){
            revert MintLimitReached(account_);
        }

        uint256 expectedCountAfterMint = addressBalanceForToken + amount_;

        if (expectedCountAfterMint > maxMintCountForAddress){
            revert MintAmountExceedsMaxMintLimitPerAddress();
        } 
    }

    function _updateCurrentCounts(uint256 tokenId_, uint256 amount_) internal {
        _currentMintCounts[tokenId_] += amount_;
    }

    function _checkMintableStatus(uint256 tokenId_) private view {
        uint256 maxMintCountForToken = _maxMintCountPerToken[tokenId_];

        if (maxMintCountForToken == 0){
            revert TokenIsNotMintable(tokenId_);
        }
    }

    function _setMaxMintCountForToken(uint256 tokenId_, uint256 limit_) internal {
        uint256 maxTokenMintLimitPerAddress = _maxMintCountPerAddress[tokenId_];
        if (limit_ < maxTokenMintLimitPerAddress){
            revert MaxMintLimitCannotBeSmallerThanMaxMintLimitPerAddress(maxTokenMintLimitPerAddress);
        }
        _maxMintCountPerToken[tokenId_] = limit_;
    }

    function _setMaxMintCountForAddress(uint256 tokenId_, uint256 limit_) internal {
        uint256 maxTokenMintLimit = _maxMintCountPerToken[tokenId_];
        if (limit_ > maxTokenMintLimit){
            revert MaxMintLimitPerAddressExceedsTotalSupply(maxTokenMintLimit);
        }
        _maxMintCountPerAddress[tokenId_] = limit_;
    }
}