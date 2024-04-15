// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev Interface for defining custom payment-related errors.
 */
interface IPaymentErrors {
    /**
     * @dev Error to be emitted when an invalid payment is received.
     * @param value The actual value of the payment.
     */
    error InvalidPayment(uint256 value);

    /**
     * @dev Error to be emitted when the balance of an address is insufficient.
     * @param addr The address with an insufficient balance.
     */
    error InsufficientBalance(address addr);
}
