package com.restaurant.billing.repository;

import com.restaurant.billing.dto.billing.BillCreateRequest;
import com.restaurant.billing.dto.billing.BillDetailsDto;
import com.restaurant.billing.dto.billing.BillSettleRequest;
import com.restaurant.billing.dto.billing.BillSummaryDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

public interface IBillRepository {
    DbExecutionOutput<Map<String, Object>> createBill(BillCreateRequest request, String cashierId);
    DbExecutionOutput<Map<String, Object>> settleBill(String billId, BillSettleRequest request, String cashierId);
    DbExecutionOutput<Map<String, Object>> cancelBill(String billId, String cancellationReason, String actorId);
    DbExecutionOutput<BillDetailsDto> getBillDetails(String billId);
    DbExecutionOutput<List<BillSummaryDto>> getBillList(int pageNumber, int pageSize, String status, String orderType, String paymentMode, String search, Timestamp fromDate, Timestamp toDate);
}
