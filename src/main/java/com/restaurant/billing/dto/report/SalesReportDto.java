package com.restaurant.billing.dto.report;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class SalesReportDto {

    private String fromDate;
    private String toDate;
    private BigDecimal totalSales;
    private Integer totalOrders;
    private BigDecimal totalTax;
    private BigDecimal totalDiscount;
    private List<Map<String, Object>> dailyTrend;

    public SalesReportDto() {}

    public String getFromDate() {
        return fromDate;
    }

    public void setFromDate(String fromDate) {
        this.fromDate = fromDate;
    }

    public String getToDate() {
        return toDate;
    }

    public void setToDate(String toDate) {
        this.toDate = toDate;
    }

    public BigDecimal getTotalSales() {
        return totalSales;
    }

    public void setTotalSales(BigDecimal totalSales) {
        this.totalSales = totalSales;
    }

    public Integer getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(Integer totalOrders) {
        this.totalOrders = totalOrders;
    }

    public BigDecimal getTotalTax() {
        return totalTax;
    }

    public void setTotalTax(BigDecimal totalTax) {
        this.totalTax = totalTax;
    }

    public BigDecimal getTotalDiscount() {
        return totalDiscount;
    }

    public void setTotalDiscount(BigDecimal totalDiscount) {
        this.totalDiscount = totalDiscount;
    }

    public List<Map<String, Object>> getDailyTrend() {
        return dailyTrend;
    }

    public void setDailyTrend(List<Map<String, Object>> dailyTrend) {
        this.dailyTrend = dailyTrend;
    }
}
