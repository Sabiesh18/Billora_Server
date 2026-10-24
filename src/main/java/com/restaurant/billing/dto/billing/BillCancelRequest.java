package com.restaurant.billing.dto.billing;

import jakarta.validation.constraints.NotBlank;

public class BillCancelRequest {

    @NotBlank(message = "Cancellation reason is mandatory for auditing")
    private String reason;

    public BillCancelRequest() {}

    public BillCancelRequest(String reason) {
        this.reason = reason;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}
