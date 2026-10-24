package com.restaurant.billing.service;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.table.RestaurantTableDto;
import com.restaurant.billing.repository.ITableRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TableService {

    private final ITableRepository tableRepository;

    public TableService(ITableRepository tableRepository) {
        this.tableRepository = tableRepository;
    }

    public DbExecutionOutput<RestaurantTableDto> createTable(RestaurantTableDto dto, String actorId) {
        return tableRepository.createTable(dto, actorId);
    }

    public DbExecutionOutput<RestaurantTableDto> updateTableStatus(String tableId, String status, String currentBillId, String actorId) {
        return tableRepository.updateTableStatus(tableId, status, currentBillId, actorId);
    }

    public DbExecutionOutput<List<RestaurantTableDto>> getAllTables() {
        return tableRepository.getAllTables();
    }
}
