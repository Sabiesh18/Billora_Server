package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.restaurant.billing.dto.billing.BillCreateRequest;
import com.restaurant.billing.dto.billing.BillDetailsDto;
import com.restaurant.billing.dto.billing.BillSettleRequest;
import com.restaurant.billing.dto.billing.BillSummaryDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.exception.AppException;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

@Repository
public class BillRepositoryImpl implements IBillRepository {

    private final DbQueryUtils dbQueryUtils;
    private final ObjectMapper objectMapper;

    public BillRepositoryImpl(DbQueryUtils dbQueryUtils, ObjectMapper objectMapper) {
        this.dbQueryUtils = dbQueryUtils;
        this.objectMapper = objectMapper;
    }

    @Override
    @SuppressWarnings("unchecked")
    public DbExecutionOutput<Map<String, Object>> createBill(BillCreateRequest request, String cashierId) {
        try {
            String itemsJson = objectMapper.writeValueAsString(request.getItems());
            Object[] params = new Object[]{
                    request.getOrderType(),
                    request.getTableId(),
                    request.getCustomerName(),
                    request.getCustomerPhone(),
                    itemsJson,
                    request.getDiscountType(),
                    request.getDiscountValue(),
                    request.getNotes(),
                    cashierId != null ? cashierId : "CASHIER"
            };
            return (DbExecutionOutput<Map<String, Object>>) (DbExecutionOutput<?>) dbQueryUtils.executeFunction("fn_CreateBill", params, Map.class);
        } catch (Exception ex) {
            throw new AppException("BILL_JSON_ERROR", "Failed to parse bill items: " + ex.getMessage());
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public DbExecutionOutput<Map<String, Object>> settleBill(String billId, BillSettleRequest request, String cashierId) {
        Object[] params = new Object[]{
                billId,
                request.getPaymentMode(),
                request.getAmountPaid(),
                request.getNotes(),
                cashierId != null ? cashierId : "CASHIER"
        };
        return (DbExecutionOutput<Map<String, Object>>) (DbExecutionOutput<?>) dbQueryUtils.executeFunction("fn_SettleBill", params, Map.class);
    }

    @Override
    @SuppressWarnings("unchecked")
    public DbExecutionOutput<Map<String, Object>> cancelBill(String billId, String cancellationReason, String actorId) {
        Object[] params = new Object[]{
                billId,
                cancellationReason,
                actorId != null ? actorId : "SYSTEM"
        };
        return (DbExecutionOutput<Map<String, Object>>) (DbExecutionOutput<?>) dbQueryUtils.executeFunction("fn_CancelBill", params, Map.class);
    }

    @Override
    public DbExecutionOutput<BillDetailsDto> getBillDetails(String billId) {
        Object[] params = new Object[]{billId};
        return dbQueryUtils.executeFunction("fn_GetBillDetails", params, BillDetailsDto.class);
    }

    @Override
    public DbExecutionOutput<List<BillSummaryDto>> getBillList(int pageNumber, int pageSize, String status, String orderType, String paymentMode, String search, Timestamp fromDate, Timestamp toDate) {
        Object[] params = new Object[]{
                pageNumber,
                pageSize,
                status,
                orderType,
                paymentMode,
                search,
                fromDate,
                toDate
        };
        return dbQueryUtils.executeFunctionForList("fn_GetBillList", params, new TypeReference<List<BillSummaryDto>>() {});
    }
}
