package com.restaurant.billing.dto.report;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class DashboardMetricsDto {

    private String metricDate;
    private BigDecimal todaySales;
    private Integer todayOrders;
    private Integer activeBills;
    private Integer occupiedTables;
    private Integer totalTables;
    private Double occupancyRate;
    private List<Map<String, Object>> topSellingItems;
    private List<Map<String, Object>> paymentBreakdown;

    public DashboardMetricsDto() {}

    public String getMetricDate() {
        return metricDate;
    }

    public void setMetricDate(String metricDate) {
        this.metricDate = metricDate;
    }

    public BigDecimal getTodaySales() {
        return todaySales;
    }

    public void setTodaySales(BigDecimal todaySales) {
        this.todaySales = todaySales;
    }

    public Integer getTodayOrders() {
        return todayOrders;
    }

    public void setTodayOrders(Integer todayOrders) {
        this.todayOrders = todayOrders;
    }

    public Integer getActiveBills() {
        return activeBills;
    }

    public void setActiveBills(Integer activeBills) {
        this.activeBills = activeBills;
    }

    public Integer getOccupiedTables() {
        return occupiedTables;
    }

    public void setOccupiedTables(Integer occupiedTables) {
        this.occupiedTables = occupiedTables;
    }

    public Integer getTotalTables() {
        return totalTables;
    }

    public void setTotalTables(Integer totalTables) {
        this.totalTables = totalTables;
    }

    public Double getOccupancyRate() {
        return occupancyRate;
    }

    public void setOccupancyRate(Double occupancyRate) {
        this.occupancyRate = occupancyRate;
    }

    public List<Map<String, Object>> getTopSellingItems() {
        return topSellingItems;
    }

    public void setTopSellingItems(List<Map<String, Object>> topSellingItems) {
        this.topSellingItems = topSellingItems;
    }

    public List<Map<String, Object>> getPaymentBreakdown() {
        return paymentBreakdown;
    }

    public void setPaymentBreakdown(List<Map<String, Object>> paymentBreakdown) {
        this.paymentBreakdown = paymentBreakdown;
    }
}
