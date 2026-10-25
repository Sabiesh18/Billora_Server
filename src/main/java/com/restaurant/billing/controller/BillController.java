package com.restaurant.billing.controller;

import com.restaurant.billing.dto.billing.*;
import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.service.BillingService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bills")
public class BillController extends BaseController {

    private final BillingService billingService;

    public BillController(BillingService billingService) {
        this.billingService = billingService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Object>> createBill(@Valid @RequestBody BillCreateRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String cashier = auth != null ? auth.getName() : "CASHIER";

        DbExecutionOutput<Map<String, Object>> output = billingService.createBill(request, cashier);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @GetMapping("/{billId}")
    public ResponseEntity<ApiResponse<Object>> getBillDetails(@PathVariable String billId) {
        DbExecutionOutput<BillDetailsDto> output = billingService.getBillDetails(billId);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping("/{billId}/settle")
    public ResponseEntity<ApiResponse<Object>> settleBill(
            @PathVariable String billId,
            @Valid @RequestBody BillSettleRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String cashier = auth != null ? auth.getName() : "CASHIER";

        DbExecutionOutput<Map<String, Object>> output = billingService.settleBill(billId, request, cashier);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping("/{billId}/cancel")
    public ResponseEntity<ApiResponse<Object>> cancelBill(
            @PathVariable String billId,
            @Valid @RequestBody BillCancelRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "USER";

        DbExecutionOutput<Map<String, Object>> output = billingService.cancelBill(billId, request.getReason(), actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Object>> getBillList(
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "15") int pageSize,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String orderType,
            @RequestParam(required = false) String paymentMode,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime toDate) {

        Timestamp fromTs = fromDate != null ? Timestamp.valueOf(fromDate) : null;
        Timestamp toTs = toDate != null ? Timestamp.valueOf(toDate) : null;

        DbExecutionOutput<List<BillSummaryDto>> output = billingService.getBillList(pageNumber, pageSize, status, orderType, paymentMode, search, fromTs, toTs);
        return generateResponse(output.getExecutionResult(), output.getData());
    }
}
