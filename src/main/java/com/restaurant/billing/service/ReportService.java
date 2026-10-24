package com.restaurant.billing.service;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.report.DashboardMetricsDto;
import com.restaurant.billing.dto.report.SalesReportDto;
import com.restaurant.billing.repository.IReportRepository;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.LocalDate;

@Service
public class ReportService {

    private final IReportRepository reportRepository;

    public ReportService(IReportRepository reportRepository) {
        this.reportRepository = reportRepository;
    }

    public DbExecutionOutput<DashboardMetricsDto> getDashboardMetrics(LocalDate date) {
        Date sqlDate = date != null ? Date.valueOf(date) : Date.valueOf(LocalDate.now());
        return reportRepository.getDashboardMetrics(sqlDate);
    }

    public DbExecutionOutput<SalesReportDto> getSalesReport(LocalDate fromDate, LocalDate toDate, String paymentMode, String cashierId) {
        Date sqlFrom = fromDate != null ? Date.valueOf(fromDate) : Date.valueOf(LocalDate.now().minusDays(30));
        Date sqlTo = toDate != null ? Date.valueOf(toDate) : Date.valueOf(LocalDate.now());
        return reportRepository.getSalesReport(sqlFrom, sqlTo, paymentMode, cashierId);
    }
}
