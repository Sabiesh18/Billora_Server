package com.restaurant.billing.dto.asset;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AssetDto {

    @JsonProperty("assetId")
    private String assetId;

    @JsonProperty("assetCode")
    private String assetCode;

    @NotBlank(message = "Asset name is required")
    @JsonProperty("assetName")
    private String assetName;

    @JsonProperty("category")
    private String category;

    @JsonProperty("vendorId")
    private String vendorId;

    @JsonProperty("vendorName")
    private String vendorName;

    @JsonProperty("purchaseDate")
    private String purchaseDate;

    @JsonProperty("costPrice")
    private BigDecimal costPrice;

    @JsonProperty("quantity")
    private Integer quantity;

    @JsonProperty("locationArea")
    private String locationArea;

    @JsonProperty("conditionStatus")
    private String conditionStatus;

    @JsonProperty("warrantyExpiry")
    private String warrantyExpiry;

    @JsonProperty("notes")
    private String notes;

    @JsonProperty("createdAt")
    private String createdAt;

    @JsonProperty("updatedAt")
    private String updatedAt;

    public AssetDto() {
    }

    public String getAssetId() {
        return assetId;
    }

    public void setAssetId(String assetId) {
        this.assetId = assetId;
    }

    public String getAssetCode() {
        return assetCode;
    }

    public void setAssetCode(String assetCode) {
        this.assetCode = assetCode;
    }

    public String getAssetName() {
        return assetName;
    }

    public void setAssetName(String assetName) {
        this.assetName = assetName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getVendorId() {
        return vendorId;
    }

    public void setVendorId(String vendorId) {
        this.vendorId = vendorId;
    }

    public String getVendorName() {
        return vendorName;
    }

    public void setVendorName(String vendorName) {
        this.vendorName = vendorName;
    }

    public String getPurchaseDate() {
        return purchaseDate;
    }

    public void setPurchaseDate(String purchaseDate) {
        this.purchaseDate = purchaseDate;
    }

    public BigDecimal getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(BigDecimal costPrice) {
        this.costPrice = costPrice;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getLocationArea() {
        return locationArea;
    }

    public void setLocationArea(String locationArea) {
        this.locationArea = locationArea;
    }

    public String getConditionStatus() {
        return conditionStatus;
    }

    public void setConditionStatus(String conditionStatus) {
        this.conditionStatus = conditionStatus;
    }

    public String getWarrantyExpiry() {
        return warrantyExpiry;
    }

    public void setWarrantyExpiry(String warrantyExpiry) {
        this.warrantyExpiry = warrantyExpiry;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
}
