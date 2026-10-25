package com.restaurant.billing.dto.asset;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;

@JsonIgnoreProperties(ignoreUnknown = true)
public class AssetSummaryDto {

    @JsonProperty("totalAssetValue")
    private BigDecimal totalAssetValue;

    @JsonProperty("totalAssetsCount")
    private Integer totalAssetsCount;

    @JsonProperty("totalVendorsCount")
    private Integer totalVendorsCount;

    @JsonProperty("totalPurchasesAmount")
    private BigDecimal totalPurchasesAmount;

    @JsonProperty("operationalAssetsCount")
    private Integer operationalAssetsCount;

    @JsonProperty("maintenanceAssetsCount")
    private Integer maintenanceAssetsCount;

    public AssetSummaryDto() {
    }

    public BigDecimal getTotalAssetValue() {
        return totalAssetValue;
    }

    public void setTotalAssetValue(BigDecimal totalAssetValue) {
        this.totalAssetValue = totalAssetValue;
    }

    public Integer getTotalAssetsCount() {
        return totalAssetsCount;
    }

    public void setTotalAssetsCount(Integer totalAssetsCount) {
        this.totalAssetsCount = totalAssetsCount;
    }

    public Integer getTotalVendorsCount() {
        return totalVendorsCount;
    }

    public void setTotalVendorsCount(Integer totalVendorsCount) {
        this.totalVendorsCount = totalVendorsCount;
    }

    public BigDecimal getTotalPurchasesAmount() {
        return totalPurchasesAmount;
    }

    public void setTotalPurchasesAmount(BigDecimal totalPurchasesAmount) {
        this.totalPurchasesAmount = totalPurchasesAmount;
    }

    public Integer getOperationalAssetsCount() {
        return operationalAssetsCount;
    }

    public void setOperationalAssetsCount(Integer operationalAssetsCount) {
        this.operationalAssetsCount = operationalAssetsCount;
    }

    public Integer getMaintenanceAssetsCount() {
        return maintenanceAssetsCount;
    }

    public void setMaintenanceAssetsCount(Integer maintenanceAssetsCount) {
        this.maintenanceAssetsCount = maintenanceAssetsCount;
    }
}
