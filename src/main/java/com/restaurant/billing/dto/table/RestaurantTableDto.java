package com.restaurant.billing.dto.table;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class RestaurantTableDto {

    private String tableId;

    @NotBlank(message = "Table number is mandatory")
    private String tableNumber;

    @Min(value = 1, message = "Seating capacity must be at least 1")
    private Integer seatingCapacity = 4;

    private String locationArea = "Main Dining";
    private String status = "AVAILABLE"; // AVAILABLE, OCCUPIED, BILLED, RESERVED
    private String currentBillId;
    private String billNumber;
    private BigDecimal grandTotal;
    private String billCreatedAt;

    public RestaurantTableDto() {}

    public String getTableId() {
        return tableId;
    }

    public void setTableId(String tableId) {
        this.tableId = tableId;
    }

    public String getTableNumber() {
        return tableNumber;
    }

    public void setTableNumber(String tableNumber) {
        this.tableNumber = tableNumber;
    }

    public Integer getSeatingCapacity() {
        return seatingCapacity;
    }

    public void setSeatingCapacity(Integer seatingCapacity) {
        this.seatingCapacity = seatingCapacity;
    }

    public String getLocationArea() {
        return locationArea;
    }

    public void setLocationArea(String locationArea) {
        this.locationArea = locationArea;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCurrentBillId() {
        return currentBillId;
    }

    public void setCurrentBillId(String currentBillId) {
        this.currentBillId = currentBillId;
    }

    public String getBillNumber() {
        return billNumber;
    }

    public void setBillNumber(String billNumber) {
        this.billNumber = billNumber;
    }

    public BigDecimal getGrandTotal() {
        return grandTotal;
    }

    public void setGrandTotal(BigDecimal grandTotal) {
        this.grandTotal = grandTotal;
    }

    public String getBillCreatedAt() {
        return billCreatedAt;
    }

    public void setBillCreatedAt(String billCreatedAt) {
        this.billCreatedAt = billCreatedAt;
    }
}
