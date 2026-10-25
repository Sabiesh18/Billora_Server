package com.restaurant.billing.service;

import com.restaurant.billing.dto.billing.BillCreateRequest;
import com.restaurant.billing.dto.billing.BillDetailsDto;
import com.restaurant.billing.dto.billing.BillItemDto;
import com.restaurant.billing.dto.billing.BillSettleRequest;
import com.restaurant.billing.dto.billing.BillSummaryDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.exception.AppException;
import com.restaurant.billing.repository.IBillRepository;
import com.restaurant.billing.util.CalculationUtils;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;

@Service
public class BillingService {

    private final IBillRepository billRepository;

    public BillingService(IBillRepository billRepository) {
        this.billRepository = billRepository;
    }

    public DbExecutionOutput<Map<String, Object>> createBill(BillCreateRequest request, String cashierId) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new AppException("EMPTY_BILL", "Cannot process a bill with no line items");
        }

        // Validate and recompute all line items on backend to prevent client-side tamper
        for (BillItemDto item : request.getItems()) {
            if (item.getQuantity() == null || item.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
                throw new AppException("INVALID_QTY", "Quantity for item '" + item.getItemName() + "' must be greater than zero");
            }
            if (item.getUnitPrice() == null || item.getUnitPrice().compareTo(BigDecimal.ZERO) < 0) {
                throw new AppException("INVALID_PRICE", "Unit price for item '" + item.getItemName() + "' cannot be negative");
            }

            BigDecimal itemTotal = CalculationUtils.calculateItemTotal(item.getQuantity(), item.getUnitPrice());
            item.setTotalPrice(itemTotal);

            BigDecimal taxAmount = CalculationUtils.calculateTax(itemTotal, item.getTaxRate());
            item.setTaxAmount(taxAmount);
        }

        return billRepository.createBill(request, cashierId);
    }

    public DbExecutionOutput<Map<String, Object>> settleBill(String billId, BillSettleRequest request, String cashierId) {
        if (request.getAmountPaid() == null || request.getAmountPaid().compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("INVALID_PAYMENT", "Payment amount must be greater than zero");
        }
        return billRepository.settleBill(billId, request, cashierId);
    }

    public DbExecutionOutput<Map<String, Object>> cancelBill(String billId, String cancellationReason, String actorId) {
        if (cancellationReason == null || cancellationReason.trim().isEmpty()) {
            throw new AppException("MISSING_REASON", "A cancellation reason must be provided for audit tracking");
        }
        return billRepository.cancelBill(billId, cancellationReason, actorId);
    }

    public DbExecutionOutput<BillDetailsDto> getBillDetails(String billId) {
        return billRepository.getBillDetails(billId);
    }

    public DbExecutionOutput<List<BillSummaryDto>> getBillList(int pageNumber, int pageSize, String status, String orderType, String paymentMode, String search, Timestamp fromDate, Timestamp toDate) {
        return billRepository.getBillList(pageNumber, pageSize, status, orderType, paymentMode, search, fromDate, toDate);
    }
}
