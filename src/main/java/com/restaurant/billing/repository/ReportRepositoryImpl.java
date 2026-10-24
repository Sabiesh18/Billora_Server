package com.restaurant.billing.repository;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.report.DashboardMetricsDto;
import com.restaurant.billing.dto.report.SalesReportDto;
import org.springframework.stereotype.Repository;

import java.sql.Date;

@Repository
public class ReportRepositoryImpl implements IReportRepository {

    private final DbQueryUtils dbQueryUtils;

    public ReportRepositoryImpl(DbQueryUtils dbQueryUtils) {
        this.dbQueryUtils = dbQueryUtils;
    }

    @Override
    public DbExecutionOutput<DashboardMetricsDto> getDashboardMetrics(Date date) {
        Object[] params = new Object[]{date != null ? date : new Date(System.currentTimeMillis())};
        return dbQueryUtils.executeFunction("fn_GetDashboardMetrics", params, DashboardMetricsDto.class);
    }

    @Override
    public DbExecutionOutput<SalesReportDto> getSalesReport(Date fromDate, Date toDate, String paymentMode, String cashierId) {
        Object[] params = new Object[]{
                fromDate,
                toDate,
                paymentMode,
                cashierId
        };
        return dbQueryUtils.executeFunction("fn_GetSalesReport", params, SalesReportDto.class);
    }
}
