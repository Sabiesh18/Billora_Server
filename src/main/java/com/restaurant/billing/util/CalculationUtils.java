package com.restaurant.billing.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Standardized Financial & Billing Calculation Engine.
 * Guarantees arithmetic consistency, precise tax calculation, and uniform rounding.
 */
public final class CalculationUtils {

    private CalculationUtils() {}

    public static final BigDecimal HUNDRED = new BigDecimal("100.00");
    public static final int MONEY_SCALE = 2;

    /**
     * Calculates line item total: (quantity * unitPrice)
     */
    public static BigDecimal calculateItemTotal(BigDecimal quantity, BigDecimal unitPrice) {
        if (quantity == null || unitPrice == null) {
            return BigDecimal.ZERO.setScale(MONEY_SCALE, RoundingMode.HALF_UP);
        }
        return quantity.multiply(unitPrice).setScale(MONEY_SCALE, RoundingMode.HALF_UP);
    }

    /**
     * Calculates tax amount on a taxable amount given the percentage rate.
     */
    public static BigDecimal calculateTax(BigDecimal taxableAmount, BigDecimal taxRate) {
        if (taxableAmount == null || taxRate == null || taxRate.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO.setScale(MONEY_SCALE, RoundingMode.HALF_UP);
        }
        return taxableAmount.multiply(taxRate).divide(HUNDRED, MONEY_SCALE, RoundingMode.HALF_UP);
    }

    /**
     * Calculates discount amount based on discount type (PERCENT or FLAT).
     */
    public static BigDecimal calculateDiscount(BigDecimal subTotal, String discountType, BigDecimal discountValue) {
        if (subTotal == null || discountValue == null || discountValue.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO.setScale(MONEY_SCALE, RoundingMode.HALF_UP);
        }

        if ("PERCENT".equalsIgnoreCase(discountType)) {
            BigDecimal effectiveRate = discountValue.min(HUNDRED).max(BigDecimal.ZERO);
            return subTotal.multiply(effectiveRate).divide(HUNDRED, MONEY_SCALE, RoundingMode.HALF_UP);
        } else if ("FLAT".equalsIgnoreCase(discountType)) {
            return discountValue.min(subTotal).max(BigDecimal.ZERO).setScale(MONEY_SCALE, RoundingMode.HALF_UP);
        }

        return BigDecimal.ZERO.setScale(MONEY_SCALE, RoundingMode.HALF_UP);
    }

    /**
     * Standard round-off to nearest integer (standard POS practice in India/offline billing).
     * Returns the adjustment value (e.g., -0.30 or +0.40).
     */
    public static BigDecimal calculateRoundOff(BigDecimal amount) {
        if (amount == null) return BigDecimal.ZERO.setScale(MONEY_SCALE, RoundingMode.HALF_UP);
        BigDecimal rounded = amount.setScale(0, RoundingMode.HALF_UP).setScale(MONEY_SCALE, RoundingMode.HALF_UP);
        return rounded.subtract(amount);
    }
}
