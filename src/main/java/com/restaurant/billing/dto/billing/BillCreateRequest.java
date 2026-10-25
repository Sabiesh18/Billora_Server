package com.restaurant.billing.dto.billing;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

public class BillCreateRequest {

    @NotNull(message = "Order type is mandatory (DINE_IN, TAKEAWAY, DELIVERY)")
    private String orderType = "DINE_IN";

    private String tableId;
    private String customerName;
    private String customerPhone;

    @NotEmpty(message = "Bill must contain at least one item")
    @Valid
    private List<BillItemDto> items;

    private String discountType = "NONE"; // PERCENT, FLAT, NONE
    private BigDecimal discountValue = BigDecimal.ZERO;
    private String notes;

    public BillCreateRequest() {}

    public String getOrderType() {
        return orderType;
    }

    public void setOrderType(String orderType) {
        this.orderType = orderType;
    }

    public String getTableId() {
        return tableId;
    }

    public void setTableId(String tableId) {
        this.tableId = tableId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public List<BillItemDto> getItems() {
        return items;
    }

    public void setItems(List<BillItemDto> items) {
        this.items = items;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
