package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.table.RestaurantTableDto;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class TableRepositoryImpl implements ITableRepository {

    private final DbQueryUtils dbQueryUtils;

    public TableRepositoryImpl(DbQueryUtils dbQueryUtils) {
        this.dbQueryUtils = dbQueryUtils;
    }

    @Override
    public DbExecutionOutput<RestaurantTableDto> createTable(RestaurantTableDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getTableNumber(),
                dto.getSeatingCapacity(),
                dto.getLocationArea(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_TableCreate", params, RestaurantTableDto.class);
    }

    @Override
    public DbExecutionOutput<RestaurantTableDto> updateTableStatus(String tableId, String status, String currentBillId, String actorId) {
        Object[] params = new Object[]{
                tableId,
                status,
                currentBillId,
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_TableUpdateStatus", params, RestaurantTableDto.class);
    }

    @Override
    public DbExecutionOutput<List<RestaurantTableDto>> getAllTables() {
        return dbQueryUtils.executeFunctionForList("fn_TableGetAll", new Object[]{}, new TypeReference<List<RestaurantTableDto>>() {});
    }
}
