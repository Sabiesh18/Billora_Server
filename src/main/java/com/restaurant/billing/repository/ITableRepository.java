package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.table.RestaurantTableDto;
import org.springframework.stereotype.Repository;

import java.util.List;

public interface ITableRepository {
    DbExecutionOutput<RestaurantTableDto> createTable(RestaurantTableDto dto, String actorId);
    DbExecutionOutput<RestaurantTableDto> updateTableStatus(String tableId, String status, String currentBillId, String actorId);
    DbExecutionOutput<List<RestaurantTableDto>> getAllTables();
}
