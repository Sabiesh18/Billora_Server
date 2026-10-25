package com.restaurant.billing.controller;

import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.table.RestaurantTableDto;
import com.restaurant.billing.service.TableService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/tables")
public class TableController extends BaseController {

    private final TableService tableService;

    public TableController(TableService tableService) {
        this.tableService = tableService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Object>> getAllTables() {
        DbExecutionOutput<List<RestaurantTableDto>> output = tableService.getAllTables();
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Object>> createTable(@Valid @RequestBody RestaurantTableDto dto) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "USER";

        DbExecutionOutput<RestaurantTableDto> output = tableService.createTable(dto, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PatchMapping("/{tableId}/status")
    public ResponseEntity<ApiResponse<Object>> updateStatus(
            @PathVariable String tableId,
            @RequestBody Map<String, String> payload) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "USER";

        String status = payload.get("status");
        String billId = payload.get("billId");

        DbExecutionOutput<RestaurantTableDto> output = tableService.updateTableStatus(tableId, status, billId, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }
}
