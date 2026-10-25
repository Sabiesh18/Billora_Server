package com.restaurant.billing.repository;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.report.DashboardMetricsDto;
import com.restaurant.billing.dto.report.SalesReportDto;

import java.sql.Date;

public interface IReportRepository {
    DbExecutionOutput<DashboardMetricsDto> getDashboardMetrics(Date date);
    DbExecutionOutput<SalesReportDto> getSalesReport(Date fromDate, Date toDate, String paymentMode, String cashierId);
}
