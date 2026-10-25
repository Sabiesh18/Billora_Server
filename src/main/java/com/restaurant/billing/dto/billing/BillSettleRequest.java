package com.restaurant.billing.dto.billing;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class BillSettleRequest {

    @NotBlank(message = "Payment mode is required (CASH, CARD, UPI, SPLIT)")
    private String paymentMode;

    @NotNull(message = "Amount paid is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Amount paid must be greater than zero")
    private BigDecimal amountPaid;

    private String notes;

    public BillSettleRequest() {}

    public String getPaymentMode() {
        return paymentMode;
    }

    public void setPaymentMode(String paymentMode) {
        this.paymentMode = paymentMode;
    }

    public BigDecimal getAmountPaid() {
        return amountPaid;
    }

    public void setAmountPaid(BigDecimal amountPaid) {
        this.amountPaid = amountPaid;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
