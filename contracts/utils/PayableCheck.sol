// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/errors/IPaymentErrors.sol";

/**
 * @dev This abstract contract provides functionality for checking and handling payments.
 */
abstract contract PayableCheck is IPaymentErrors{
    
    /**
     * @dev Internal function to check if the received payment is greater than zero.
     * If the payment is zero, it reverts with an `InvalidPayment` error.
     * @param expectedPaymentAmount_ The expected payment amount.
     */
    function _paymentMustBeGreaterThanZero(uint256 expectedPaymentAmount_) internal virtual {
        if (_isZero(_msgValue())){
            revert InvalidPayment(_msgValue(), expectedPaymentAmount_);
        }
    }

    /**
     * @dev Internal function to check if the received payment is equal to the expected payment amount.
     * If the payment is not equal, it reverts with an `InvalidPayment` error.
     * @param expectedPaymentAmount_ The expected payment amount.
     */
    function _paymentMustBeEqualToExpectedPaymentAmount(uint256 expectedPaymentAmount_) internal virtual {
        if (_msgValue() != expectedPaymentAmount_){
            revert InvalidPayment(_msgValue(), expectedPaymentAmount_);
        }
    }

    /**
     * @dev Internal function to check if the balance of the given address is not insufficient.
     * If the balance is zero, it reverts with an `InsufficientBalance` error.
     * @param addr_ The address to check the balance.
     */
    function _balanceMustNotBeInsufficient(address addr_) internal virtual {
        if(_isZero(addr_.balance)){
            revert InsufficientBalance(addr_);
        }
    }

    /**
     * @dev Private function to check if a value is zero.
     * @param value_ The value to check.
     * @return Whether the value is zero or not.
     */
    function _isZero(uint256 value_) private pure returns(bool) {
        if(value_ > 0) {
            return false;
        }
        return true;
    }

    /**
     * @dev Internal function to get the value of the current payment.
     * @return The value of the current payment.
     */
    function _msgValue() private returns(uint256){
        return msg.value;
    }
}